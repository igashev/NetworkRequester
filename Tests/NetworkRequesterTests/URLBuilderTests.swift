import XCTest
@testable import NetworkRequester

final class URLBuilderTests: XCTestCase {
    func testInitializationIsCorrect() {
        let environment = "some cool environment"
        let endpoint = "some cool endpoint"
        let queryItems = [URLQueryItem(name: "item name", value: "item value")]
        let builder = URLBuilder(environment: environment, endpoint: endpoint, queryParameters: queryItems)
        
        XCTAssertEqual(builder.environment, environment)
        XCTAssertEqual(builder.endpoint, endpoint)
        XCTAssertEqual(builder.queryParameters, queryItems)
    }
    
    func testURLSucceedsToBuildWithoutQueryItemsAndIsCorrect() throws {
        let environment = "www.google.com/"
        let endpoint = "v1/terrick"
        let builder = URLBuilder(environment: environment, endpoint: endpoint)
        
        let url = try XCTUnwrap(builder.build())
        XCTAssertEqual(url.absoluteString, environment + endpoint)
    }
    
    func testURLSucceedsToBuildWithQueryItems() throws {
        let environment = "www.google.com/"
        let endpoint = "v1/ivaylo"
        let queryItem = URLQueryItem(name: "itemName", value: "itemValue")
        let builder = URLBuilder(environment: environment, endpoint: endpoint, queryParameters: [queryItem])
        
        let url = try XCTUnwrap(builder.build())
        XCTAssertEqual(url.absoluteString, environment + endpoint + "?\(queryItem.name)=\(queryItem.value!)")
    }
    
    func testURLFailsToBuild() {
        let builder = URLBuilder(environment: "bad url", endpoint: "even worse url")
        XCTAssertThrowsError(try builder.build())
    }
}
