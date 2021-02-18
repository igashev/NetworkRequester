import XCTest
@testable import NetworkRequester

final class HTTPHeaderTests: XCTestCase {
    func testBearerAuthorizationHeaderIsCorrect() {
        let authorizationHeader = HTTPHeader.authorization(bearerToken: "some complex token")
        XCTAssertEqual(authorizationHeader.name, "Authorization")
        XCTAssertEqual(authorizationHeader.value, "Bearer some complex token")
    }
    
    func testAuthorizationHeaderIsCorrect() {
        let authorizationHeader = HTTPHeader.authorization(token: "some token")
        XCTAssertEqual(authorizationHeader.name, "Authorization")
        XCTAssertEqual(authorizationHeader.value, "some token")
    }
}
