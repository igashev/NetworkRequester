import Foundation
import Combine

public class NetworkRequestCaller {
    
    public let decoder: JSONDecoder
    public let urlSession: URLSession
    
    public init(decoder: JSONDecoder = JSONDecoder(), urlSession: URLSession = .shared) {
        self.decoder = decoder
        self.urlSession = urlSession
    }
    
    public func call<Model: Decodable>(request: URLRequest) -> AnyPublisher<Model, Error> {
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
                print(error)
                if let decodingError = error as? DecodingError {
                    return NetworkingError.responseDecodingFailure(error: decodingError)
                } else if let networkingError = error as? NetworkingError {
                    return networkingError
                } else {
                    return NetworkingError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
