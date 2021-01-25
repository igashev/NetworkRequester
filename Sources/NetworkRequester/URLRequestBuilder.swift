import Foundation

public struct URLRequestBuilder {
    public var environment: String { urlBuilder.environment }
    public var endpoint: String { urlBuilder.endpoint }
    public var fullUrl: String { urlBuilder.fullUrl }
    public let defaultHeaders: [HTTPHeader] = [.json]
    
    public let httpMethod: HTTPMethod
    public let httpBody: HTTPBody?
    public let httpHeaders: Set<HTTPHeader>
    public let queryParameters: [URLQueryItem]
    public let timeoutInterval: TimeInterval
    
    private let urlBuilder: URLBuilder
    
    public init(
        environment: URLProviding,
        endpoint: URLProviding,
        httpMethod: HTTPMethod,
        httpHeaders: [HTTPHeader] = [],
        httpBody: HTTPBody? = nil,
        queryParameters: [URLQueryItem] = [],
        timeoutInterval: TimeInterval
    ) {
        self.httpMethod = httpMethod
        self.httpBody = httpBody
        self.httpHeaders = Set(httpHeaders + defaultHeaders)
        self.queryParameters = queryParameters
        self.timeoutInterval = timeoutInterval
        
        self.urlBuilder = URLBuilder(environment: environment.url, endpoint: endpoint.url, queryParameters: queryParameters)
    }
    
    public func build() throws -> URLRequest {
        let buildedUrl = try urlBuilder.build()
        
        var request = URLRequest(url: buildedUrl)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = httpMethod.description
        request.httpBody = try httpBody?.data()
        request.addHeaders(defaultHeaders)
        return request
    }
}
