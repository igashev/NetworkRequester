import Foundation

/// Use this object to create a complete `URLRequests`.
public struct URLRequestBuilder {
    
    /// The hostname or the domain name.
    public let environment: String
    
    /// The path to a specific resource.
    public let endpoint: String
    
    /// The full URL which is constructed by combining `environment` + `endpoint` + `queryParameters`.
    /// Will return empty string when a complete URL could not be constructed.
    public var fullUrl: String {
        guard let url = try? buildedURL() else {
            return ""
        }
        
        return url.absoluteString
    }
    
    /// The query parameters.
    public var queryParameters: [URLQueryItem] {
        guard let queryParameters = _queryParameters,
              let items = try? queryParameters.items()
        else {
            return []
        }
        
        return items
    }
    
    /// The HTTP method.
    public let httpMethod: HTTPMethod
    
    /// The HTTP body.
    public let httpBody: HTTPBody?
    
    /// The HTTP headers.
    public let httpHeaders: Set<HTTPHeader>
    
    /// The timeout interval after which the request will be cancelled.
    public let timeoutInterval: TimeInterval
    
    private let _queryParameters: URLQueryParameters?
    
    /// Initialising the builder with the desired request properties that can build the complete `URLRequest`.
    /// - Parameters:
    ///   - environment: The hostname of a URL.
    ///   - endpoint: The path to a specific resource of a URL.
    ///   - httpMethod: The HTTP method of the request.
    ///   - httpHeaders: The HTTP headers of the request.
    ///   - httpBody: The HTTP body of the request. Not required.
    ///   - queryParameters: The URL query parameters of a URL. Not required.
    ///   - timeoutInterval: The timeout interval of a request. Defaults to *30*.
    public init(
        environment: URLProviding,
        endpoint: URLProviding,
        httpMethod: HTTPMethod,
        httpHeaders: [HTTPHeader] = [],
        httpBody: HTTPBody? = nil,
        queryParameters: URLQueryParameters? = nil,
        timeoutInterval: TimeInterval = 30
    ) {
        self.environment = environment.url
        self.endpoint = endpoint.url
        self.httpMethod = httpMethod
        self.httpBody = httpBody
        self.httpHeaders = Set(httpHeaders)
        self._queryParameters = queryParameters
        self.timeoutInterval = timeoutInterval
    }
    
    /// Builds the `URLRequest` by using the provided properties when initialising the builder.
    /// - Throws: `NetworkingError.buildingURL` if it fails to build the URL or
    ///  `NetworkingError.encoding(error:)` if it fails to encode the HTTP body.
    /// - Returns: A fully configured `URLRequest` that is ready to be used.
    public func build() throws -> URLRequest {
        let buildedUrl = try buildedURL()
        var request = URLRequest(url: buildedUrl)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = String(describing: httpMethod)
        request.httpBody = try httpBody?.data()
        request.addHeaders(httpHeaders)
        return request
    }
    
    /// Builds the URL.
    /// - Throws: `NetworkingError.buildingURL` if it fails to build the URL
    /// - Returns: Full URL.
    private func buildedURL() throws -> URL {
        let queryParameters = try _queryParameters?.items() ?? []
        let urlBuilder = URLBuilder(environment: environment, endpoint: endpoint, queryParameters: queryParameters)
        return try urlBuilder.build()
    }
}
