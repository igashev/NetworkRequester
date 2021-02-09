import Foundation

struct URLBuilder {
    let environment: String
    let endpoint: String
    let queryParameters: [URLQueryItem]
    
    init(environment: String, endpoint: String, queryParameters: [URLQueryItem] = []) {
        self.environment = environment
        self.endpoint = endpoint
        self.queryParameters = queryParameters
    }
    
    func build() throws -> URL {
        guard var urlComponents = URLComponents(string: environment) else {
            throw NetworkingError.buildingURL
        }
        
        guard urlComponents.scheme != nil else {
            throw NetworkingError.buildingURL
        }
        
        var endpointCopy = endpoint
        
        // Checks whether an additional slash is needed in order to construct a valid URL.
        let shouldAddAdditionalSlash = !endpointCopy.hasPrefix(Constants.slash)
        if shouldAddAdditionalSlash {
            endpointCopy.insert("/", at: endpointCopy.startIndex)
        }
        
        urlComponents.path = endpointCopy
        
        if !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters
        }
        
        guard let composedUrl = urlComponents.url else {
            throw NetworkingError.buildingURL
        }
        
        return composedUrl
    }
}

private enum Constants {
    static let slash = "/"
}
