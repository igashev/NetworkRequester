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
        let environment = "https://google.com"
        let endpoint = "v1/perfect"
        let builder = URLBuilder(environment: environment, endpoint: endpoint)
        
        let url = try XCTUnwrap(builder.build())
        XCTAssertEqual(url.absoluteString, "\(environment)/\(endpoint)")
    }
    
    func testURLSucceedsToBuildWithQueryItems() throws {
        let environment = "https://google.com"
        let endpoint = "v1/perfect15"
        let queryItem = URLQueryItem(name: "itemName", value: "itemValue")
        let builder = URLBuilder(environment: environment, endpoint: endpoint, queryParameters: [queryItem])
        
        let url = try XCTUnwrap(builder.build())
        XCTAssertEqual(url.absoluteString, "\(environment)/\(endpoint)?\(queryItem.name)=\(queryItem.value!)")
    }
    
    func testURLFailsToBuild() {
        let builder = URLBuilder(environment: "bad url", endpoint: "even worse url")
        XCTAssertThrowsError(try builder.build())
    }
    
    func testURLWithoutSchemeFails() {
        let builder = URLBuilder(environment: "www.google.com", endpoint: "v1/goto")
        XCTAssertThrowsError(try builder.build())
    }
}
