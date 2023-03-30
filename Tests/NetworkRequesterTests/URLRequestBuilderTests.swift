import XCTest
@testable import NetworkRequester

final class URLRequestBuilderTests: XCTestCase {
    func testInitsCorrectly() {
        let encodableBody = Body(name: "some great name", personalNumber: 8531235)
        let httpBody = HTTPBody(encodable: encodableBody, jsonEncoder: .init())
        
        let queryParams: [URLQueryItem] = [.init(name: "firstName", value: "someCoolFirstName")]
        let urlQueryParams = URLQueryParameters(queryItems: queryParams)
        
        let httpMethod = HTTPMethod.get
        let timeoutInterval: TimeInterval = 60
        
        let requestBuilder = URLRequestBuilder(
            environment: Environment(),
            endpoint: Endpoint(),
            httpMethod: httpMethod,
            httpHeaders: [.json],
            httpBody: httpBody,
            queryParameters: urlQueryParams,
            timeoutInterval: timeoutInterval
        )
        
        XCTAssertEqual(requestBuilder.environment, Environment().url)
        XCTAssertEqual(requestBuilder.endpoint, Endpoint().url)
        XCTAssertEqual(requestBuilder.url, "http://some-cool-domain-name.com/some/cool/path?firstName=someCoolFirstName")
        XCTAssertEqual(requestBuilder.queryParameters.sorted(by: { $0.name > $1.name }), queryParams.sorted(by: { $0.name > $1.name }))
        XCTAssertEqual(requestBuilder.httpMethod, httpMethod)
        XCTAssertEqual(requestBuilder.httpHeaders, [HTTPHeader.json])
        XCTAssertNotNil(requestBuilder.httpBody)
        XCTAssertEqual(requestBuilder.timeoutInterval, timeoutInterval)
    }
    
    func testBuildingURLRequestSucceeds() throws {
        let encodableBody = Body(name: "some great name", personalNumber: 8531235)
        let httpBody = HTTPBody(encodable: encodableBody, jsonEncoder: .init())
        
        let queryParams: [URLQueryItem] = [.init(name: "firstName", value: "someCoolFirstName")]
        let urlQueryParams = URLQueryParameters(queryItems: queryParams)
        
        let httpMethod = HTTPMethod.get
        let timeoutInterval: TimeInterval = 60
        
        let requestBuilder = URLRequestBuilder(
            environment: Environment(),
            endpoint: Endpoint(),
            httpMethod: httpMethod,
            httpHeaders: [.json],
            httpBody: httpBody,
            queryParameters: urlQueryParams,
            timeoutInterval: timeoutInterval
        )
        
        let request = try requestBuilder.build()
        XCTAssertEqual(request.url?.absoluteString, "http://some-cool-domain-name.com/some/cool/path?firstName=someCoolFirstName")
        XCTAssertEqual(request.httpMethod, String(describing: httpMethod.description))
        XCTAssertEqual(request.httpBody, try httpBody.data())
        XCTAssertEqual(request.allHTTPHeaderFields, [HTTPHeader.json.name: HTTPHeader.json.value])
        XCTAssertEqual(request.timeoutInterval, timeoutInterval)
    }
    
    func testInitWithWrongURL() {
        let requestBuilder = URLRequestBuilder(environment: InvalidEnvironment(), endpoint: Endpoint(), httpMethod: .get)
        XCTAssertTrue(requestBuilder.url.isEmpty)
    }
    
    func testInitWithWrongQuery() {
        let requestBuilder = URLRequestBuilder(
            environment: Environment(),
            endpoint: Endpoint(),
            httpMethod: .get,
            queryParameters: .init(encodable: QueryParameter(age: .infinity), encoder: .init())
        )
        
        XCTAssertTrue(requestBuilder.queryParameters.isEmpty)
    }
}

private extension URLRequestBuilderTests {
    struct Environment: URLProviding {
        let url: String = "http://some-cool-domain-name.com"
    }
    
    struct InvalidEnvironment: URLProviding {
        let url = "www.some-bad-domain-name.co"
    }
    
    struct Endpoint: URLProviding {
        let url: String = "some/cool/path"
    }
    
    struct Body: Encodable {
        let name: String
        let personalNumber: Int
    }
    
    struct QueryParameter: Encodable {
        let age: Double
    }
}
