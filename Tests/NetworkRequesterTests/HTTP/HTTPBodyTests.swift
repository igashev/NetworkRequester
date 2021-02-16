import XCTest
@testable import NetworkRequester

final class HTTPBodyTests: XCTestCase {
    func testBodyEncodingSucceeds() throws {
        let codable = TestCodable(name: "Codable name", age: 12)
        let body = HTTPBody(encodable: codable, jsonEncoder: .init())
        XCTAssertNoThrow(try body.data())
    }
    
    func testBodyEncodingFails() {
        let body = HTTPBody(encodable: Double.infinity, jsonEncoder: .init())
        XCTAssertThrowsError(try body.data()) { error in
            XCTAssertTrue(error is NetworkingError)
            
            guard let error = error as? NetworkingError else {
                XCTFail("Wrong error is thrown.")
                return
            }
            
            switch error {
            case .encoding:
                break
            default:
                XCTFail("Wrong error is thrown.")
            }
        }
    }
    
    func testDataEncodingCorrectly() throws {
        let codable = TestCodable(name: "some codable strange name", age: 19)
        let body = try HTTPBody(encodable: codable, jsonEncoder: .init()).data()
        let decodedData = try JSONDecoder().decode(TestCodable.self, from: body)
        XCTAssertEqual(decodedData, codable)
    }
}

extension HTTPBodyTests {
    private struct TestCodable: Codable, Equatable {
        let name: String
        let age: Int
    }
}
