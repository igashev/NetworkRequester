import Foundation
import Combine

/// Use this object to make network calls and receive decoded values wrapped into Combine's `AnyPublisher`.
public struct URLRequestCaller {
    
    /// Session object which is used to make the actual network call.
    public let urlSession: URLSession
    
    /// Decoder which decodes the received data from the network call.
    public let decoder: JSONDecoder
    
    /// Initialises an object which can make network calls.
    /// - Parameters:
    ///   - urlSession: The session that would make the actual network call. Defaults to `.shared`.
    ///   - decoder: The decoder that would decode the received data from the network call.
    public init(urlSession: URLSession = .shared, decoder: JSONDecoder) {
        self.urlSession = urlSession
        self.decoder = decoder
    }
    
    /// Method which calls the network request.
    /// - Parameter request: The `URLRequest` that should be called.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    @available(iOS 13.0, *)
    public func call<D: Decodable>(request: URLRequest) -> AnyPublisher<D, NetworkingError> {
        urlSession.dataTaskPublisher(for: request)
            .tryMap { try Self.tryMapResponse(data: $0.data, urlResponse: $0.response) }
            .map { Self.mapDataToEmptyIfNeeded(data: $0, type: D.self) }
            .decode(type: D.self, decoder: decoder)
            .mapError { Self.mapError($0)}
            .eraseToAnyPublisher()
    }
    
    /// Convenient method which calls the builded network request using the `URLRequestBuilder` object. The building and the error handling of the `URLRequest` are handled here.
    /// - Parameter builder: The builder from which the `URLRequest` will be constructed and called.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    @available(iOS 13.0, *)
    public func call<D: Decodable>(builder: URLRequestBuilder) -> AnyPublisher<D, NetworkingError> {
        do {
            let urlRequest = try builder.build()
            return call(request: urlRequest)
        } catch {
            let error = error as? NetworkingError ?? .unknown
            return Fail(error: error)
                .eraseToAnyPublisher()
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
    
    private static func mapDataToEmptyIfNeeded<T>(data: Data, type: T.Type) -> Data {
        T.self == EmptyResponse.self ? EmptyResponse.emptyJSON : data
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
