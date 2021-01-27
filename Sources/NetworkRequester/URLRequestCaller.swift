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
    public func call<Model: Decodable>(request: URLRequest) -> AnyPublisher<Model, NetworkingError> {
        urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    let status = HTTPStatus(rawValue: httpResponse.statusCode)
                else {
                    throw NetworkingError.failure(.internalServerError)
                }
                
                if status.isSuccess {
                    return data
                } else {
                    throw NetworkingError.failure(status)
                }
            }
            .decode(type: Model.self, decoder: decoder)
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return NetworkingError.decodingFailure(error: decodingError)
                } else if let networkingError = error as? NetworkingError {
                    return networkingError
                } else {
                    return NetworkingError.unknown
                }
            }
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
        } catch let error as NetworkingError {
            return Fail(error: error)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .mapError { _ in .unknown }
                .eraseToAnyPublisher()
        }
    }
}
