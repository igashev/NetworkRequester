import XCTest
@testable import NetworkRequester

final class URLQueryParametersTests: XCTestCase {
    func testInitUsingEncodable() throws {
        let encodable = TestEncodable(name: "some inital name", age: 15)
        let queryParameters = URLQueryParameters(encodable: encodable, encoder: .init())
        
        XCTAssertNoThrow(try queryParameters.items())
        
        let queryItems = try queryParameters.items()
        XCTAssertEqual(queryItems.count, 2)
        
        let expectedResult: [URLQueryItem] = [
            .init(name: "name", value: encodable.name),
            .init(name: "age", value: String(describing: encodable.age))
        ]
        .sorted(by: { $0.name < $1.name })
        
        XCTAssertEqual(queryItems.sorted(by: { $0.name < $1.name }), expectedResult.sorted(by: { $0.name < $1.name }))
    }
    
    func testInitUsingURLQueryItems() throws {
        let paramsToAdd: [URLQueryItem] = [
            .init(name: "name", value: "some inital nameeeeee"),
            .init(name: "age2", value: String(describing: 15)),
            .init(name: "someothername", value: nil)
        ]
        
        let queryParameters = URLQueryParameters(queryItems: paramsToAdd)
        XCTAssertNoThrow(try queryParameters.items())
        
        let queryItems = try queryParameters.items()
        XCTAssertEqual(paramsToAdd.sorted(by: { $0.name < $1.name }), queryItems.sorted(by: { $0.name < $1.name }))
    }
}

private extension URLQueryParametersTests {
    struct TestEncodable: Encodable {
        let name: String
        let age: Int
    }
}
