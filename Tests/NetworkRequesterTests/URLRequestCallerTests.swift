//import XCTest
//import Combine
//@testable import NetworkRequester
//
//final class URLRequestCallerTests: XCTestCase {
//
//    struct TestError: Error, Codable, Equatable {
//        let message: String
//    }
//
//    private var encodedData: Data {
//        let testableModel = TestEncodable(name: "first name", age: 1236)
//        return try! JSONEncoder().encode(testableModel)
//    }
//
//    private var encodedTestErrorData: Data {
//        let testableError = TestError(message: "Something went wrong")
//        return try! JSONEncoder().encode(testableError)
//    }
//    
//    private let decoder = JSONDecoder()
//    private let request = URLRequest(url: URL(string: "https://google.com")!)
//    private var cancellables = Set<AnyCancellable>()
//    
//    func testCallSucceeds() {
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { [encodedData] _ in
//                Just((encodedData, .withStatus(200)))
//                    .setFailureType(to: CombineCaller.AnyURLSessionDataPublisher.Failure.self)
//                    .eraseToAnyPublisher()
//            }
//        )
//        
//        let testObjectResponsePublisher: AnyPublisher<TestEncodable, NetworkingError> = caller
//            .call(using: request, errorType: TestError.self)
//
//        testObjectResponsePublisher.sink(
//            receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    XCTFail("Expected to receive value. Got error: \(error)")
//                case .finished:
//                    break
//                }
//            },
//            receiveValue: { data in
//                XCTAssertEqual(data.name, "first name")
//                XCTAssertEqual(data.age, 1236)
//            }
//        )
//        .store(in: &cancellables)
//    }
//    
//    func testCallFailsDueToURLError() {
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { _ in Fail(error: URLError(.badURL)).eraseToAnyPublisher() }
//        )
//        
//        caller.call(using: URLRequest(url: URL(string: "https://google.com")!), errorType: TestError.self)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        switch error {
//                        case .unknown:
//                            break
//                        default:
//                            XCTFail("A wrong error is thrown. Expected NetworkingError.unknown, got \(error).")
//                        }
//                    case .finished:
//                        XCTFail("Expected NetworkingError.unknown, got .finished completion.")
//                    }
//                },
//                receiveValue: { data in XCTFail("Expected NetworkingError.unknown, got \(data).") }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func testCallFailsDueToInvalidHTTPResponse() {
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { [encodedTestErrorData] _ in
//                Just((encodedTestErrorData, .withStatus(1000)))
//                    .setFailureType(to: CombineCaller.AnyURLSessionDataPublisher.Failure.self)
//                    .eraseToAnyPublisher()
//            }
//        )
//        
//        caller.call(using: URLRequest(url: URL(string: "https://google.com")!), errorType: TestError.self)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        switch error {
//                        case .networking(let status, let decodedError):
//                            switch status {
//                            case .internalServerError:
//                                XCTAssertEqual(decodedError as? TestError, TestError(message: "Something went wrong"))
//                            default:
//                                XCTFail("A wrong error is thrown. Expected NetworkingError.networking(status: .internalServerError), got \(error).")
//                            }
//                        default:
//                            XCTFail("A wrong error is thrown. Expected NetworkingError.unknown, got \(error).")
//                        }
//                    case .finished:
//                        XCTFail("Expected NetworkingError.unknown, got .finished completion.")
//                    }
//                },
//                receiveValue: { data in XCTFail("Expected NetworkingError.unknown, got \(data).") }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func testCallFailsDueToBadRequest() {
//        let didRequestExpectation = XCTestExpectation.calledOnce(description: "onRequest called")
//        let didReceiveExpectation = XCTestExpectation.calledOnce(description: "onResponse called")
//        let didErrorExpecatation = XCTestExpectation.calledOnce(description: "onError called")
//
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { [encodedTestErrorData] _ in
//                Just((encodedTestErrorData, .withStatus(HTTPStatus.badRequest.code)))
//                    .setFailureType(to: CombineCaller.AnyURLSessionDataPublisher.Failure.self)
//                    .eraseToAnyPublisher()
//            },
//            middleware: [
//                TestMiddleware(
//                    onRequestExpectation: didRequestExpectation,
//                    onResponseExpectation: didReceiveExpectation,
//                    onErrorExpectation: didErrorExpecatation
//                )
//            ]
//        )
//        
//        caller.call(using: URLRequest(url: URL(string: "https://google.com")!), errorType: TestError.self)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        switch error {
//                        case .networking(let status, let decodedError):
//                            switch status {
//                            case .badRequest:
//                                XCTAssertEqual(decodedError as? TestError, TestError(message: "Something went wrong"))
//                            default:
//                                XCTFail("A wrong error is thrown. Expected NetworkingError.networking(status: .badRequest), got \(error).")
//                            }
//                        default:
//                            XCTFail("A wrong error is thrown. Expected NetworkingError.unknown, got \(error).")
//                        }
//                    case .finished:
//                        XCTFail("Expected NetworkingError.unknown, got .finished completion.")
//                    }
//                },
//                receiveValue: { data in XCTFail("Expected NetworkingError.unknown, got \(data).") }
//            )
//            .store(in: &cancellables)
//        
//        wait(for: [didRequestExpectation, didReceiveExpectation, didErrorExpecatation], timeout: 0.5)
//    }
//    
//    func testResponseToBeIntButGotEmpty() {
//        let didRequestExpectation = XCTestExpectation.calledOnce(description: "onRequest called")
//        let didReceiveExpectation = XCTestExpectation.calledOnce(description: "onResponse called")
//        let didErrorExpecatation = XCTestExpectation.calledOnce(description: "onError called")
//        
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { _ in
//                Just((data: .init(), response: .withStatus(200)))
//                    .setFailureType(to: CombineCaller.AnyURLSessionDataPublisher.Failure.self)
//                    .eraseToAnyPublisher()
//            },
//            middleware: [
//                TestMiddleware(
//                    onRequestExpectation: didRequestExpectation,
//                    onResponseExpectation: didReceiveExpectation,
//                    onErrorExpectation: didErrorExpecatation
//                )
//            ]
//        )
//        
//        let intResponsePublisher: AnyPublisher<Int, NetworkingError> = caller.call(using: request, errorType: TestError.self)
//        intResponsePublisher
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        switch error {
//                        case .decoding:
//                            break
//                        default:
//                            XCTFail("A wrong error is thrown. Expected NetworkingError.decoding(error: DecodingError), got \(error).")
//                        }
//                    case .finished:
//                        XCTFail("Expected NetworkingError.decoding(error: DecodingError), got .finished completion.")
//                    }
//                },
//                receiveValue: { data in XCTFail("Expected NetworkingError.decoding(error: DecodingError), got \(data).") }
//            )
//            .store(in: &cancellables)
//        
//        wait(for: [didRequestExpectation, didReceiveExpectation, didErrorExpecatation], timeout: 0.5)
//    }
//    
//    func testResponseToBeEmptyButGotData() {
//        let didRequestExpectation = XCTestExpectation.calledOnce(description: "onRequest called")
//        let didReceiveExpectation = XCTestExpectation.calledOnce(description: "onResponse called")
//        let didErrorExpecatation = XCTestExpectation.calledOnce(description: "onError called")
//
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { [encodedData] _ in
//                Just((data: encodedData, response: .withStatus(200)))
//                    .setFailureType(to: CombineCaller.AnyURLSessionDataPublisher.Failure.self)
//                    .eraseToAnyPublisher()
//            },
//            middleware: [
//                TestMiddleware(
//                    onRequestExpectation: didRequestExpectation,
//                    onResponseExpectation: didReceiveExpectation,
//                    onErrorExpectation: didErrorExpecatation
//                )
//            ]
//        )
//        
//        caller.call(using: request, errorType: TestError.self)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        switch error {
//                        case .decoding:
//                            break
//                        default:
//                            XCTFail("A wrong error is thrown. Expected NetworkingError.decoding(error: DecodingError), got \(error).")
//                        }
//                    case .finished:
//                        XCTFail("Expected NetworkingError.decoding(error: DecodingError), got .finished completion.")
//                    }
//                },
//                receiveValue: { data in XCTFail("Expected NetworkingError.decoding(error: DecodingError), got \(data).") }
//            )
//            .store(in: &cancellables)
//        
//        wait(for: [didRequestExpectation, didReceiveExpectation, didErrorExpecatation], timeout: 0.5)
//    }
//    
//    func testResponseToBeEmptyAndGotEmpty() {
//        let didRequestExpectation = XCTestExpectation.calledOnce(description: "onRequest called")
//        let didReceiveExpecatation = XCTestExpectation.calledOnce(description: "onResponse called")
//
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { _ in
//                Just((data: .init(), response: .withStatus(200)))
//                    .setFailureType(to: CombineCaller.AnyURLSessionDataPublisher.Failure.self)
//                    .eraseToAnyPublisher()
//            },
//            middleware: [
//                TestMiddleware(
//                    onRequestExpectation: didRequestExpectation,
//                    onResponseExpectation: didReceiveExpecatation
//                )
//            ]
//        )
//        
//        caller.call(using: request, errorType: TestError.self)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        XCTFail("Expected to receive value. Got error: \(error)")
//                    case .finished:
//                        break
//                    }
//                },
//                receiveValue: { _ in }
//            )
//            .store(in: &cancellables)
//        
//        wait(for: [didRequestExpectation, didReceiveExpecatation], timeout: 0.5)
//    }
//    
//    func testResponseToBeEmptyAndGotEmptyUsingURLRequestBuilder() {
//        let didRequestExpectation = XCTestExpectation.calledOnce(description: "onRequest called")
//        let didReceiveExpecatation = XCTestExpectation.calledOnce(description: "onResponse called")
//        
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { _ in
//                Just((data: .init(), response: .withStatus(200)))
//                    .setFailureType(to: CombineCaller.AnyURLSessionDataPublisher.Failure.self)
//                    .eraseToAnyPublisher()
//            },
//            middleware: [
//                TestMiddleware(
//                    onRequestExpectation: didRequestExpectation,
//                    onResponseExpectation: didReceiveExpecatation
//                )
//            ]
//        )
//        
//        let builder = URLRequestBuilder(environment: Environment(), endpoint: Environment(), httpMethod: .get)
//        caller.call(using: builder, errorType: TestError.self)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        XCTFail("Expected to receive value. Got error: \(error)")
//                    case .finished:
//                        break
//                    }
//                },
//                receiveValue: { _ in }
//            )
//            .store(in: &cancellables)
//        
//        wait(for: [didRequestExpectation, didReceiveExpecatation], timeout: 0.5)
//    }
//    
//    func testResponseToBeEmptyToFailDueToBuilderError() {
//        let shouldErrorExpectation = expectation(description: "onError called expected")
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { _ in
//                Just((data: .init(), response: .withStatus(200)))
//                    .setFailureType(to: CombineCaller.AnyURLSessionDataPublisher.Failure.self)
//                    .eraseToAnyPublisher()
//            },
//            middleware: [TestMiddleware(onErrorExpectation: shouldErrorExpectation)]
//        )
//        
//        let builder = URLRequestBuilder(environment: Environment(url: "dad asdas"), endpoint: Environment(url: "dad asdas"), httpMethod: .get)
//        caller.call(using: builder, errorType: TestError.self)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        switch error {
//                        case .buildingURL:
//                            break
//                        default:
//                            XCTFail("A wrong error is thrown. Expected NetworkingError.buildingURL, got \(error).")
//                        }
//                    case .finished:
//                        XCTFail("Expected NetworkingError.buildingURL, got .finished completion.")
//                    }
//                },
//                receiveValue: { data in XCTFail("Expected NetworkingError.buildingURL, got \(data).") }
//            )
//            .store(in: &cancellables)
//        
//        wait(for: [shouldErrorExpectation], timeout: 0.5)
//    }
//    
//    func testResponseDataToFailDueToBuilderError() {
//        let shouldErrorExpectation = expectation(description: "onError called expected")
//        let caller = CombineCaller(
//            decoder: decoder,
//            getDataPublisher: { _ in
//                Just((data: .init(), response: .withStatus(200)))
//                    .setFailureType(to: CombineCaller.AnyURLSessionDataPublisher.Failure.self)
//                    .eraseToAnyPublisher()
//            },
//            middleware: [TestMiddleware(onErrorExpectation: shouldErrorExpectation)]
//        )
//        let builder = URLRequestBuilder(
//            environment: Environment(url: "dad asdas"),
//            endpoint: Environment(url: "dad asdas"),
//            httpMethod: .get
//        )
//        let intResponsePublisher: AnyPublisher<Int, NetworkingError> = caller.call(
//            using: builder,
//            errorType: TestError.self
//        )
//        
//        intResponsePublisher
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        switch error {
//                        case .buildingURL:
//                            break
//                        default:
//                            XCTFail("A wrong error is thrown. Expected NetworkingError.buildingURL, got \(error).")
//                        }
//                    case .finished:
//                        XCTFail("Expected NetworkingError.buildingURL, got .finished completion.")
//                    }
//                },
//                receiveValue: { data in XCTFail("Expected NetworkingError.buildingURL, got \(data).") }
//            )
//            .store(in: &cancellables)
//        
//        wait(for: [shouldErrorExpectation], timeout: 0.5)
//    }
//}
//
//private class TestMiddleware: Middleware {
//
//    let onRequestExpectation: XCTestExpectation
//    let onResponseExpectation: XCTestExpectation
//    let onErrorExpectation: XCTestExpectation
//    
//    init(
//        onRequestExpectation: XCTestExpectation = .failing(description: "onRequest called"),
//        onResponseExpectation: XCTestExpectation = .failing(description: "onResponse called"),
//        onErrorExpectation: XCTestExpectation = .failing(description: "onError called")
//    ) {
//        self.onRequestExpectation = onRequestExpectation
//        self.onResponseExpectation = onResponseExpectation
//        self.onErrorExpectation = onErrorExpectation
//    }
//    
//    // MARK: URLRequestPlugable
//    
//    func onRequest(_ request: URLRequest) {
//        onRequestExpectation.fulfill()
//    }
//    
//    func onResponse(data: Data, response: URLResponse) {
//        onResponseExpectation.fulfill()
//    }
//    
//    func onError(_ error: NetworkingError, request: URLRequest?) {
//        onErrorExpectation.fulfill()
//    }
//}
//
//private extension XCTestExpectation {
//    static func failing(description: String) -> XCTestExpectation {
//        let expectation = XCTestExpectation(description: description)
//        expectation.expectedFulfillmentCount = 1
//        expectation.fulfill()
//        expectation.assertForOverFulfill = true
//        return expectation
//    }
//    
//    static func calledOnce(description: String) -> XCTestExpectation {
//        let expectation = XCTestExpectation(description: description)
//        expectation.expectedFulfillmentCount = 1
//        expectation.assertForOverFulfill = true
//        return expectation
//    }
//}
//
//private extension URLRequestCallerTests {
//    struct TestEncodable: Codable {
//        let name: String
//        let age: Int
//    }
//    
//    struct Environment: URLProviding {
//        var url: String = "https://google.com"
//    }
//}
//
//private extension URLResponse {
//    static func withStatus(_ status: Int) -> HTTPURLResponse {
//        HTTPURLResponse(
//            url: URL(string: "https://google.com")!,
//            statusCode: status,
//            httpVersion: nil,
//            headerFields: nil
//        )!
//    }
//}
