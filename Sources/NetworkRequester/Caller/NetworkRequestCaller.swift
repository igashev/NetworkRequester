import Foundation

public class NetworkRequestCaller {
    
    private let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    public func call<Model: Decodable>(
        withRequest request: URLRequest,
        response: @escaping (Result<Model, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: request) { [weak self] (data, urlResponse, error) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                response(.failure(error))
            } else {
                do {
                    guard let data = data else {
                        throw ResponseError.noDataReceived
                    }
                    
                    guard let httpResponse = urlResponse as? HTTPURLResponse else {
                        throw ResponseError.invalidResponseType
                    }
                    
                    let status = ResponseStatus(statusCode: httpResponse.statusCode)
                    switch status {
                    case .success:
                        let responseObject = try strongSelf.decoder.decode(Model.self, from: data)
                        response(.success(responseObject))
                    default:
                        throw ResponseError.responseError(status)
                    }
                } catch {
                    response(.failure(error))
                }
            }
        }.resume()
    }
}
