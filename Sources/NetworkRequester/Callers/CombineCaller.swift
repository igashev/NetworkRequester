import Combine
import Foundation

/// Use this object to make network calls and receive decoded values wrapped into Combine's `AnyPublisher`.
public struct CombineCaller {
    public typealias AnyURLSessionDataPublisher = AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>

    private let middleware: [URLRequestPlugable]
    private let utility: CallerUtility
    
    /// Gets the data task publisher.
    private let getDataDataTaskPublisher: (URLRequest) -> AnyURLSessionDataPublisher
    
    /// Initialises an object which can make network calls.
    /// - Parameters:
    ///   - urlSession: Session that would make the actual network call.
    ///   - decoder: Decoder that would decode the received data from the network call.
    ///   - middleware: Middleware that is injected in the networking events.
    public init(urlSession: URLSession = .shared, decoder: JSONDecoder, middleware: [URLRequestPlugable] = []) {
        self.init(
            decoder: decoder,
            getDataPublisher: { urlSession.dataTaskPublisher(for: $0).eraseToAnyPublisher() },
            middleware: middleware
        )
    }

    /// Initialises an object which can make network calls.
    /// - Parameters:
    ///   - decoder: Decoder that would decode the received data from the network call.
    ///   - getDataPublisher: A closure that returns a data task publisher.
    init(
        decoder: JSONDecoder,
        getDataPublisher: @escaping (URLRequest) -> AnyURLSessionDataPublisher,
        middleware: [URLRequestPlugable] = []
    ) {
        self.middleware = middleware
        self.getDataDataTaskPublisher = getDataPublisher
        self.utility = .init(decoder: decoder)
    }

    /// Method which calls the network request.
    /// - Parameters:
    ///   - request: The `URLRequest` that should be called.
    ///   - errorType: The error type to be decoded from the body in non-success cases.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    public func call<D: Decodable, DE: DecodableError>(
        using request: URLRequest,
        errorType: DE.Type
    ) -> AnyPublisher<D, NetworkingError> {
        getDataDataTaskPublisher(request)
            .attachMiddleware(middleware, for: request)
            .tryMap { try utility.checkResponseForErrors(data: $0.data, urlResponse: $0.response, errorType: errorType) }
            .tryMap(utility.decodeIfNecessary)
            .mapError(utility.mapError)
            .attachCompletionMiddleware(middleware, request: request)
            .eraseToAnyPublisher()
    }

    /// Method which calls the network request without expecting a response body.
    /// - Parameters:
    ///   - request: The `URLRequest` that should be called.
    ///   - errorType: The error type to be decoded from the body in non-success cases.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    public func call<DE: DecodableError>(
        using request: URLRequest,
        errorType: DE.Type
    ) -> AnyPublisher<Void, NetworkingError> {
        getDataDataTaskPublisher(request)
            .attachMiddleware(middleware, for: request)
            .tryMap { try utility.checkResponseForErrors(data: $0.data, urlResponse: $0.response, errorType: errorType) }
            .tryMap(utility.tryMapEmptyResponseBody(data:))
            .mapError(utility.mapError)
            .attachCompletionMiddleware(middleware, request: request)
            .eraseToAnyPublisher()
    }
}

public extension CombineCaller {
    /// Convenient method which calls the builded network request using the `URLRequestBuilder` object.
    /// The building and the error handling of the `URLRequest` are handled here.
    /// - Parameters:
    ///   - builder: The builder from which the `URLRequest` will be constructed and called.
    ///   - errorType: The error type to be decoded from the body in non-success cases.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    func call<D: Decodable, E: DecodableError>(
        using builder: URLRequestBuilder,
        errorType: E.Type
    ) -> AnyPublisher<D, NetworkingError> {
        do {
            let urlRequest = try builder.build()
            return call(using: urlRequest, errorType: errorType)
        } catch {
            return Fail(error: utility.mapError(error))
                .attachCompletionMiddleware(middleware, request: nil)
                .eraseToAnyPublisher()
        }
    }

    /// Convenient method which calls the builded network request using the `URLRequestBuilder` object without expecting a response body.
    /// The building and the error handling of the `URLRequest` are handled here.
    /// - Parameters:
    ///   - builder: The builder from which the `URLRequest` will be constructed and called.
    ///   - errorType: The error type to be decoded from the body in non-success cases.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    func call<E: DecodableError>(
        using builder: URLRequestBuilder,
        errorType: E.Type
    ) -> AnyPublisher<Void, NetworkingError> {
        do {
            let urlRequest = try builder.build()
            return call(using: urlRequest, errorType: errorType)
        } catch {
            return Fail(error: utility.mapError(error))
                .attachCompletionMiddleware(middleware, request: nil)
                .eraseToAnyPublisher()
        }
    }
}

private extension CombineCaller.AnyURLSessionDataPublisher {
    func attachMiddleware(
        _ middleware: [URLRequestPlugable],
        for request: URLRequest
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveSubscription: { _ in
                middleware.forEach { $0.onRequest(request) }
            },
            receiveOutput: { data, response in
                middleware.forEach { $0.onResponse(data: data, response: response) }
            }
        )
    }
}

private extension Publisher where Failure == NetworkingError {
    func attachCompletionMiddleware(
        _ middleware: [URLRequestPlugable],
        request: URLRequest?
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                middleware.forEach { $0.onError(error, request: request) }
            default:
                return
            }
        })
    }
}
