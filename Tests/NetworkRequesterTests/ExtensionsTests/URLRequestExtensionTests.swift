import XCTest
@testable import NetworkRequester

final class URLRequestExtensionTests: XCTestCase {
    func testAddHeaders() throws {
        var request = URLRequest(url: URL(string: "https://google.com")!)
        
        let header1 = HTTPHeader(name: "headerField", value: "headerValue")
        request.addHeader(header1)
        
        let header2 = HTTPHeader(name: "headerField2", value: "headerValue2")
        request.addHeader(header2)
        
        let header1Value = try XCTUnwrap(request.value(forHTTPHeaderField: "headerField"))
        XCTAssertEqual(header1Value, "headerValue")
        
        let header2Value = try XCTUnwrap(request.value(forHTTPHeaderField: "headerField2"))
        XCTAssertEqual(header2Value, "headerValue2")
    }
    
    func testAddMultipleHeadersAtOnce() throws {
        var request = URLRequest(url: URL(string: "https://google.com")!)
        
        let header1 = HTTPHeader(name: "headerField", value: "headerValue")
        let header2 = HTTPHeader(name: "headerField2", value: "headerValue2")
        request.addHeaders([header1, header2])
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertEqual(headers.count, 2)
        
        let header1Value = try XCTUnwrap(headers["headerField"])
        XCTAssertEqual(header1Value, "headerValue")
        
        let header2Value = try XCTUnwrap(headers["headerField2"])
        XCTAssertEqual(header2Value, "headerValue2")
    }
    
    func testAddMulpleHeadersWithTheSameName() throws {
        let header1 = HTTPHeader.authorization(bearerToken: "secret-bearer-token")
        let header2 = HTTPHeader.authorization(token: "secret-auth-token")
        
        var request = URLRequest(url: URL(string: "https://google.com")!)
        request.addHeaders([header1, header2])
        
        let headers = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertEqual(headers.count, 1)
        
        let headerValue = try XCTUnwrap(headers["Authorization"])
        XCTAssertEqual(headerValue, [header1.value, header2.value].joined(separator: ","))
    }
}
