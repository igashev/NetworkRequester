import Foundation

public struct NetworkRequestBuilder {
    
    private let environment: URLProviding
    
    public init(environment: URLProviding) {
        self.environment = environment
    }
    
    public func build(
        to endpoint: URLProviding,
        httpMethod: HTTPMethod,
        body: Data? = nil,
        headers: [HTTPHeader] = [],
        queryItems: [URLQueryItem] = []) throws -> URLRequest
    {
        guard var url = URL(string: "\(environment.url)\(endpoint.url)") else {
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
        request.httpBody = body
        
        request.addHeader(HTTPHeader.json)
        for header in headers {
            request.addHeader(header)
        }
        
        return request
    }
}
