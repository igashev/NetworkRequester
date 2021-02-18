import XCTest
@testable import NetworkRequester

final class HTTPStatusTests: XCTestCase {
    func testStatusCodeIsCorrect() {
        XCTAssertEqual(HTTPStatus.processing.code, 102)
        XCTAssertEqual(HTTPStatus.accepted.code, 202)
        XCTAssertEqual(HTTPStatus.badRequest.code, 400)
        XCTAssertEqual(HTTPStatus.gone.code, 410)
        XCTAssertEqual(HTTPStatus.internalServerError.code, 500)
    }
    
    func testStatusIsInformational() {
        XCTAssertTrue(HTTPStatus.continue.isInformational)
        XCTAssertTrue(HTTPStatus.processing.isInformational)
        
        XCTAssertFalse(HTTPStatus.noContent.isInformational)
        XCTAssertFalse(HTTPStatus.seeOther.isInformational)
        XCTAssertFalse(HTTPStatus.requestURITooLong.isInformational)
        XCTAssertFalse(HTTPStatus.variantAlsoNegotiates.isInformational)
    }
    
    func testStatusIsSuccess() {
        XCTAssertTrue(HTTPStatus.ok.isSuccess)
        XCTAssertTrue(HTTPStatus.iAmUsed.isSuccess)
        
        XCTAssertFalse(HTTPStatus.switchingProtocols.isSuccess)
        XCTAssertFalse(HTTPStatus.seeOther.isSuccess)
        XCTAssertFalse(HTTPStatus.requestURITooLong.isSuccess)
        XCTAssertFalse(HTTPStatus.variantAlsoNegotiates.isSuccess)
    }
    
    func testStatusIsRedirection() {
        XCTAssertTrue(HTTPStatus.multipleChoices.isRedirection)
        XCTAssertTrue(HTTPStatus.permanentRedirect.isRedirection)
        
        XCTAssertFalse(HTTPStatus.switchingProtocols.isRedirection)
        XCTAssertFalse(HTTPStatus.noContent.isRedirection)
        XCTAssertFalse(HTTPStatus.requestURITooLong.isRedirection)
        XCTAssertFalse(HTTPStatus.variantAlsoNegotiates.isRedirection)
    }
    
    func testStatusIsClientError() {
        XCTAssertTrue(HTTPStatus.badRequest.isClientError)
        XCTAssertTrue(HTTPStatus.clientClosedRequest.isClientError)
        
        XCTAssertFalse(HTTPStatus.switchingProtocols.isClientError)
        XCTAssertFalse(HTTPStatus.noContent.isClientError)
        XCTAssertFalse(HTTPStatus.seeOther.isClientError)
        XCTAssertFalse(HTTPStatus.variantAlsoNegotiates.isClientError)
    }
    
    func testStatusIsServerError() {
        XCTAssertTrue(HTTPStatus.internalServerError.isServerError)
        XCTAssertTrue(HTTPStatus.networkConnectTimeoutError.isServerError)
        
        XCTAssertFalse(HTTPStatus.switchingProtocols.isServerError)
        XCTAssertFalse(HTTPStatus.noContent.isServerError)
        XCTAssertFalse(HTTPStatus.seeOther.isServerError)
        XCTAssertFalse(HTTPStatus.requestURITooLong.isServerError)
    }
}
