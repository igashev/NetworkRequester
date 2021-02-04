import XCTest
@testable import NetworkRequester

final class URLRequestExtensionTests: XCTestCase {
    func testAddingHeader() throws {
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
    
    func testAddingMultipleHeaders() throws {
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
}
