import Foundation

public struct NetworkRequestBuilder {
    
    private let environment: EnvironmentUrlProviding
    private let encoder: JSONEncoder
    
    public init(environment: EnvironmentUrlProviding, encoder: JSONEncoder = JSONEncoder()) {
        self.environment = environment
        self.encoder = encoder
    }
    
    public func build<T: Encodable>(
        to endpoint: UrlProviding,
        httpMethod: HTTPMethod,
        body: T? = nil,
        headers: [HTTPHeader] = [],
        queryItems: [URLQueryItem] = []) throws -> URLRequest
    {
        guard var url = URL(string: "\(environment.apiUrl)\(endpoint.url)") else {
            throw NetworkRequestBuilderError.invalidUrl
        }
        
        if !queryItems.isEmpty {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = queryItems
            
            guard let composedUrl = urlComponents?.url else {
                throw NetworkRequestBuilderError.invalidUrl
            }

            url = composedUrl
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = httpMethod.description
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        
        request.addHeader(HTTPHeader.json)
        for header in headers {
            request.addHeader(header)
        }
        
        return request
    }
}
