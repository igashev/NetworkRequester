import Foundation

public struct NetworkRequestCaller {
    
    public func call<Model: Decodable>(
        withRequest request: URLRequest,
        response: @escaping (Result<Model, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
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
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.dateDecodingStrategy = .secondsSince1970
                        
                        let responseObject = try jsonDecoder.decode(Model.self, from: data)
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
