import XCTest
@testable import NetworkRequester

final class EmptyResponseTests: XCTestCase {
    func testDecodeEmptyResponse() {
        XCTAssertNoThrow(try JSONDecoder().decode(EmptyResponse.self, from: EmptyResponse.emptyJSON))
    }
}
