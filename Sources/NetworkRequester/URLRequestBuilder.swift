import Foundation

public struct URLRequestBuilder {
    public var environment: String { _environment.url }
    public var endpoint: String { _endpoint.url }
    public var fullUrl: String { environment + endpoint }
    public var queryParameters: [URLQueryItem] {
        guard let queryParameters = _queryParameters,
              let items = try? queryParameters.items()
        else {
            return []
        }
        
        return items
    }
    
    public let httpMethod: HTTPMethod
    public let httpBody: HTTPBody?
    public let httpHeaders: Set<HTTPHeader>
    public let defaultHeaders: [HTTPHeader] = [.json]
    
    public let timeoutInterval: TimeInterval
    
    private let _environment: URLProviding
    private let _endpoint: URLProviding
    private let _queryParameters: URLQueryParameters?
    
    public init(
        environment: URLProviding,
        endpoint: URLProviding,
        httpMethod: HTTPMethod,
        httpHeaders: [HTTPHeader] = [],
        httpBody: HTTPBody? = nil,
        queryParameters: URLQueryParameters? = nil,
        timeoutInterval: TimeInterval = 30
    ) {
        self._environment = environment
        self._endpoint = endpoint
        self.httpMethod = httpMethod
        self.httpBody = httpBody
        self.httpHeaders = Set(httpHeaders + defaultHeaders)
        self._queryParameters = queryParameters
        self.timeoutInterval = timeoutInterval
    }
    
    public func build() throws -> URLRequest {
        let queryParameters = try _queryParameters?.items() ?? []
        let urlBuilder = URLBuilder(environment: _environment.url, endpoint: _endpoint.url, queryParameters: queryParameters)
        let buildedUrl = try urlBuilder.build()
        
        var request = URLRequest(url: buildedUrl)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = httpMethod.description
        request.httpBody = try httpBody?.data()
        request.addHeaders(httpHeaders)
        return request
    }
}
