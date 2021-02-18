import XCTest
@testable import NetworkRequester

final class HTTPMethodTests: XCTestCase {
    func testHTTPMethodsDescriptionIsCorrect() {
        XCTAssertEqual(String(describing: HTTPMethod.get), "GET")
        XCTAssertEqual(String(describing: HTTPMethod.post), "POST")
        XCTAssertEqual(String(describing: HTTPMethod.delete), "DELETE")
        XCTAssertEqual(String(describing: HTTPMethod.patch), "PATCH")
    }
}
