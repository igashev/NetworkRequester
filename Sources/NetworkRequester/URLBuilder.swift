import Foundation

/// Use this object to construct full URLs uncluding query parameters.
struct URLBuilder {
    /// The environment or host of a URL.
    let environment: String
    let endpoint: String
    let queryParameters: [URLQueryItem]
    
    // MARK: Constants
    
    private let slash = "/"
    
    init(environment: String, endpoint: String, queryParameters: [URLQueryItem] = []) {
        self.environment = environment
        self.endpoint = endpoint
        self.queryParameters = queryParameters
    }
    
    /// Constructs the URL using the provided `environment`, `endpoint` and `queryParameters` when this object was initialized.
    /// - Throws: `NetworkingError.buildingURL` when a valid URL could not be constructed.
    /// - Returns: A fully constructed URL.
    func build() throws -> URL {
        guard var urlComponents = URLComponents(string: environment) else {
            throw NetworkingError.buildingURL
        }
        
        guard urlComponents.scheme != nil else {
            throw NetworkingError.buildingURL
        }
        
        var endpointCopy = endpoint
        
        // Checks whether an additional slash is needed in order to construct a valid URL.
        let shouldAddAdditionalSlash = !endpointCopy.hasPrefix(slash)
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
