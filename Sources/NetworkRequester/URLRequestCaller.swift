import Foundation
import Combine

/// Use this object to make network calls and receive decoded values or `NetworkingError` errors wrapped into Combine's `AnyPublisher`.
public class URLRequestCaller {
    
    /// Decoder which decodes the received data from the network call.
    public let decoder: JSONDecoder
    
    /// Session object which is used to make the actual network call.
    public let urlSession: URLSession
    
    /// Initialises an object which can make network calls.
    /// - Parameters:
    ///   - decoder: The decoder with which to decode the received data from the network call.
    ///   - urlSession: The `URLSession` used to make the actual network call.
    public init(decoder: JSONDecoder = JSONDecoder(), urlSession: URLSession = .shared) {
        self.decoder = decoder
        self.urlSession = urlSession
    }
    
    /// Method which calls the network request.
    /// - Parameter request: The `URLRequest` that should be called.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    @available(iOS 13.0, *)
    public func call<D: Decodable>(request: URLRequest) -> AnyPublisher<D, NetworkingError> {
        urlSession.dataTaskPublisher(for: request)
            .tryMap { try Self.tryMapResponse(data: $0.data, urlResponse: $0.response) }
            .map { Self.mapDataToEmptyIfPossible(data: $0, type: D.self) }
            .decode(type: D.self, decoder: decoder)
            .mapError { Self.mapError($0)}
            .eraseToAnyPublisher()
    }
    
    /// Convenient method which calls the builded network request using the `URLRequestBuilder` object. The building and the error handling of the `URLRequest` are handled here.
    /// - Parameter builder: The builder from which the `URLRequest` will be constructed and called.
    /// - Returns: The result from the network call wrapped into `AnyPublisher`.
    @available(iOS 13.0, *)
    public func call<Model: Decodable>(builder: URLRequestBuilder) -> AnyPublisher<Model, NetworkingError> {
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
            throw NetworkingError.failure(.internalServerError)
        }
        
        guard status.isSuccess else {
            throw NetworkingError.failure(status)
        }
        
        return data
    }
    
    private static func mapDataToEmptyIfPossible<T>(data: Data, type: T.Type) -> Data {
        T.self == EmptyResponse.self ? EmptyResponse.emptyJSON : data
    }
    
    private static func mapError(_ error: Error) -> NetworkingError {
        switch error {
        case let decodingError as DecodingError:
            return NetworkingError.decodingFailure(error: decodingError)
        case let networkingError as NetworkingError:
            return networkingError
        default:
            return .unknown
        }
    }
}
