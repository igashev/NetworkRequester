import Foundation
import Combine

/// Use this object to make network calls and receive decoded values wrapped into Combine's `AnyPublisher`.
public struct URLRequestCaller {
    public typealias AnyURLSessionDataPublisher = AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>

    /// Decoder which decodes the received data from the network call.
    public let decoder: JSONDecoder
    
    /// Gets the data task publisher.
    private let getDataDataTaskPublisher: (URLRequest) -> AnyURLSessionDataPublisher
    
    /// Initialises an object which can make network calls.
    /// - Parameters:
    ///   - urlSession: Session that would make the actual network call. Defaults to `.shared`.
    ///   - decoder: Decoder that would decode the received data from the network call.
    public init(urlSession: URLSession = .shared, decoder: JSONDecoder) {
        self.init(decoder: decoder, getDataPublisher: { urlSession.dataTaskPublisher(for: $0).eraseToAnyPublisher() })
    }
    
    /// Initialises an object which can make network calls.
    /// - Parameters:
    ///   - decoder: Decoder that would decode the received data from the network call.
    ///   - getDataPublisher: A closure that returns a data task publisher.
    init(decoder: JSONDecoder, getDataPublisher: @escaping (URLRequest) -> AnyURLSessionDataPublisher) {
        self.decoder = decoder
        self.getDataDataTaskPublisher = getDataPublisher
    }
    
    /// Method which calls the network request.
    /// - Parameter request: The `URLRequest` that should be called.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    public func call<D: Decodable>(using request: URLRequest) -> AnyPublisher<D, NetworkingError> {
        getDataDataTaskPublisher(request)
            .tryMap { try Self.tryMapResponse(data: $0.data, urlResponse: $0.response) }
            .decode(type: D.self, decoder: decoder)
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }
    
    /// Method which calls the network request without expecting a response body.
    /// - Parameter request: The `URLRequest` that should be called.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    public func call(using request: URLRequest) -> AnyPublisher<Void, NetworkingError> {
        getDataDataTaskPublisher(request)
            .tryMap { try Self.tryMapResponse(data: $0.data, urlResponse: $0.response) }
            .tryMap { data in
                guard !data.isEmpty else {
                    return
                }
                
                let context = DecodingError.Context(codingPath: [], debugDescription: "Void expects empty body.")
                throw DecodingError.dataCorrupted(context)
            }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }
    
    /// Convenient method which calls the builded network request using the `URLRequestBuilder` object. The building and the error handling of the `URLRequest` are handled here.
    /// - Parameter builder: The builder from which the `URLRequest` will be constructed and called.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    public func call<D: Decodable>(using builder: URLRequestBuilder) -> AnyPublisher<D, NetworkingError> {
        do {
            let urlRequest = try builder.build()
            return call(using: urlRequest)
        } catch {
            return Fail(error: Self.mapError(error)).eraseToAnyPublisher()
        }
    }
    
    /// Convenient method which calls the builded network request using the `URLRequestBuilder` object without expecting a response body.
    /// The building and the error handling of the `URLRequest` are handled here.
    /// - Parameter builder: The builder from which the `URLRequest` will be constructed and called.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    public func call(using builder: URLRequestBuilder) -> AnyPublisher<Void, NetworkingError> {
        do {
            let urlRequest = try builder.build()
            return call(using: urlRequest)
        } catch {
            return Fail(error: Self.mapError(error)).eraseToAnyPublisher()
        }
    }
    
    private static func tryMapResponse(data: Data, urlResponse: URLResponse) throws -> Data {
        guard
            let httpResponse = urlResponse as? HTTPURLResponse,
            let status = HTTPStatus(rawValue: httpResponse.statusCode)
        else {
            throw NetworkingError.networking(.internalServerError)
        }
        
        guard status.isSuccess else {
            throw NetworkingError.networking(status)
        }
        
        return data
    }
    
    private static func mapError(_ error: Error) -> NetworkingError {
        switch error {
        case let decodingError as DecodingError:
            return NetworkingError.decoding(error: decodingError)
        case let networkingError as NetworkingError:
            return networkingError
        default:
            return .unknown
        }
    }
}
