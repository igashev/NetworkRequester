import Foundation

struct URLBuilder {
    let environment: String
    let endpoint: String
    let queryParameters: [URLQueryItem]
    
    var fullUrl: String { environment + endpoint }
    
    init(environment: String, endpoint: String, queryParameters: [URLQueryItem] = []) {
        self.environment = environment
        self.endpoint = endpoint
        self.queryParameters = queryParameters
    }
    
    func build() throws -> URL {
        guard var urlComponents = URLComponents(string: fullUrl) else {
            throw NetworkingError.buildingURLFailure
        }
        
        if !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters
        }
        
        guard let composedUrl = urlComponents.url else {
            throw NetworkingError.buildingURLFailure
        }
        
        return composedUrl
    }
}
