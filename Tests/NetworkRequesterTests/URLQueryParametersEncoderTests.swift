import XCTest
@testable import NetworkRequester

final class URLQueryParametersEncoderTests: XCTestCase {
    func testEncodingSucceedsWithoutSubtype() throws {
        let encodable = TestEncodable(name: "some name", age: 17, subtype: nil)
        let queryItems = try URLQueryParametersEncoder.encode(encodable: encodable)
        
        let expectedResult: [URLQueryItem] = [
            .init(name: "name", value: encodable.name),
            .init(name: "age", value: "17")
        ]
        .sorted(by: { $0.name < $1.name })
        
        XCTAssertEqual(expectedResult, queryItems.sorted(by: { $0.name < $1.name }))
    }
    
    func testEncodingSucceedsWithSubtype() throws {
        let encodable = TestEncodable(name: "some name", age: 17, subtype: .init(subname: "some subname", subAge: 22))
        let queryItems = try URLQueryParametersEncoder.encode(encodable: encodable)
        
        let expectedResult: [URLQueryItem] = [
            .init(name: "name", value: encodable.name),
            .init(name: "age", value: "17")
        ]
        .sorted(by: { $0.name < $1.name })
        
        XCTAssertEqual(expectedResult, queryItems.sorted(by: { $0.name < $1.name }))
    }
    
    func testEncodingReturnsEmptyBecauseJSONNotADictionary() throws {
        XCTAssertTrue(try URLQueryParametersEncoder.encode(encodable: "").isEmpty)
    }
    
    func testEncodingThrowsErrorBecauseOfInvalidJSON() {
        let encodable = TestEncodable(name: "some name", age: .infinity, subtype: nil)
        XCTAssertThrowsError(try URLQueryParametersEncoder.encode(encodable: encodable)) { error in
            XCTAssertTrue(error is NetworkingError)
            
            guard let error = error as? NetworkingError else {
                XCTFail("Wrong error is thrown.")
                return
            }
            
            switch error {
            case .buildingURLFailure:
                break
            default:
                XCTFail("Wrong error is thrown.")
            }
        }
    }
    
    func testEncodingThrowsErrorBecauseOfInvalidSubtypeJSON() {
        let encodable = TestEncodable(name: "some name", age: 22, subtype: .init(subname: "subtype name", subAge: .infinity))
        XCTAssertThrowsError(try URLQueryParametersEncoder.encode(encodable: encodable)) { error in
            XCTAssertTrue(error is NetworkingError)
            
            guard let error = error as? NetworkingError else {
                XCTFail("Wrong error is thrown.")
                return
            }
            
            switch error {
            case .buildingURLFailure:
                break
            default:
                XCTFail("Wrong error is thrown.")
            }
        }
    }
}

private extension URLQueryParametersEncoderTests {
    struct TestEncodable: Encodable {
        struct Subtype: Encodable {
            let subname: String
            let subAge: Double
        }
        
        let name: String
        let age: Double
        let subtype: Subtype?
    }
}
