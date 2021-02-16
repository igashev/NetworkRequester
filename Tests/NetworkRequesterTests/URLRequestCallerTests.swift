import XCTest
import Combine
@testable import NetworkRequester

final class URLRequestCallerTests: XCTestCase {
    private var encodedData: Data {
        let testableModel = TestEncodable(name: "first name", age: 1236)
        return try! JSONEncoder().encode(testableModel)
    }
    
    private let decoder = JSONDecoder()
    private let request = URLRequest(url: URL(string: "https://google.com")!)
    private var cancellables = Set<AnyCancellable>()
    
    func testCallSucceeds() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { [encodedData] _ in
                Just((encodedData, .withStatus(200)))
                    .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                    .eraseToAnyPublisher()
            }
        )
        
        let testObjectResponsePublisher: AnyPublisher<TestEncodable, NetworkingError> = caller.call(request: request)
        testObjectResponsePublisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Expected to receive value. Got error: \(error)")
                case .finished:
                    break
                }
            },
            receiveValue: { data in
                XCTAssertEqual(data.name, "first name")
                XCTAssertEqual(data.age, 1236)
            }
        )
        .store(in: &cancellables)
    }
    
    func testCallFailsDueToURLError() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { _ in Fail(error: URLError(.badURL)).eraseToAnyPublisher() }
        )
        
        caller.call(request: URLRequest(url: URL(string: "https://google.com")!))
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .unknown:
                            break
                        default:
                            XCTFail("A wrong error is thrown. Expected NetworkingError.unknown, got \(error).")
                        }
                    case .finished:
                        XCTFail("Expected NetworkingError.unknown, got .finished completion.")
                    }
                },
                receiveValue: { data in XCTFail("Expected NetworkingError.unknown, got \(data).") }
            )
            .store(in: &cancellables)
    }
    
    func testCallFailsDueToInvalidHTTPResponse() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { _ in
                Just((.init(), .withStatus(1000)))
                    .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                    .eraseToAnyPublisher()
            }
        )
        
        caller.call(request: URLRequest(url: URL(string: "https://google.com")!))
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .networking(let status):
                            switch status {
                            case .internalServerError:
                                break
                            default:
                                XCTFail("A wrong error is thrown. Expected NetworkingError.networking(status: .internalServerError), got \(error).")
                            }
                        default:
                            XCTFail("A wrong error is thrown. Expected NetworkingError.unknown, got \(error).")
                        }
                    case .finished:
                        XCTFail("Expected NetworkingError.unknown, got .finished completion.")
                    }
                },
                receiveValue: { data in XCTFail("Expected NetworkingError.unknown, got \(data).") }
            )
            .store(in: &cancellables)
    }
    
    func testCallFailsDueToBadRequest() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { _ in
                Just((.init(), .withStatus(HTTPStatus.badRequest.code)))
                    .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                    .eraseToAnyPublisher()
            }
        )
        
        caller.call(request: URLRequest(url: URL(string: "https://google.com")!))
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .networking(let status):
                            switch status {
                            case .badRequest:
                                break
                            default:
                                XCTFail("A wrong error is thrown. Expected NetworkingError.networking(status: .badRequest), got \(error).")
                            }
                        default:
                            XCTFail("A wrong error is thrown. Expected NetworkingError.unknown, got \(error).")
                        }
                    case .finished:
                        XCTFail("Expected NetworkingError.unknown, got .finished completion.")
                    }
                },
                receiveValue: { data in XCTFail("Expected NetworkingError.unknown, got \(data).") }
            )
            .store(in: &cancellables)
    }
    
    func testResponseToBeIntButGotEmpty() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { _ in
                Just((data: .init(), response: .withStatus(200)))
                    .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                    .eraseToAnyPublisher()
            }
        )
        
        let intResponsePublisher: AnyPublisher<Int, NetworkingError> = caller.call(request: request)
        intResponsePublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .decoding:
                            break
                        default:
                            XCTFail("A wrong error is thrown. Expected NetworkingError.decoding(error: DecodingError), got \(error).")
                        }
                    case .finished:
                        XCTFail("Expected NetworkingError.decoding(error: DecodingError), got .finished completion.")
                    }
                },
                receiveValue: { data in XCTFail("Expected NetworkingError.decoding(error: DecodingError), got \(data).") }
            )
            .store(in: &cancellables)
    }
    
    func testResponseToBeEmptyButGotData() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { [encodedData] _ in
                Just((data: encodedData, response: .withStatus(200)))
                    .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                    .eraseToAnyPublisher()
            }
        )
        
        caller.call(request: request)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .decoding:
                            break
                        default:
                            XCTFail("A wrong error is thrown. Expected NetworkingError.decoding(error: DecodingError), got \(error).")
                        }
                    case .finished:
                        XCTFail("Expected NetworkingError.decoding(error: DecodingError), got .finished completion.")
                    }
                },
                receiveValue: { data in XCTFail("Expected NetworkingError.decoding(error: DecodingError), got \(data).") }
            )
            .store(in: &cancellables)
    }
    
    func testResponseToBeEmptyAndGotEmpty() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { _ in
                Just((data: .init(), response: .withStatus(200)))
                    .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                    .eraseToAnyPublisher()
            }
        )
        
        caller.call(request: request)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail("Expected to receive value. Got error: \(error)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func testResponseToBeEmptyAndGotEmptyUsingURLRequestBuilder() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { _ in
                Just((data: .init(), response: .withStatus(200)))
                    .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                    .eraseToAnyPublisher()
            }
        )
        
        let builder = URLRequestBuilder(environment: Environment(), endpoint: Environment(), httpMethod: .get)
        caller.call(builder: builder)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail("Expected to receive value. Got error: \(error)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func testResponseToBeEmptyToFailDueToBuilderError() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { _ in
                Just((data: .init(), response: .withStatus(200)))
                    .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                    .eraseToAnyPublisher()
            }
        )
        
        let builder = URLRequestBuilder(environment: Environment(url: "dad asdas"), endpoint: Environment(url: "dad asdas"), httpMethod: .get)
        caller.call(builder: builder)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .buildingURL:
                            break
                        default:
                            XCTFail("A wrong error is thrown. Expected NetworkingError.buildingURL, got \(error).")
                        }
                    case .finished:
                        XCTFail("Expected NetworkingError.buildingURL, got .finished completion.")
                    }
                },
                receiveValue: { data in XCTFail("Expected NetworkingError.buildingURL, got \(data).") }
            )
            .store(in: &cancellables)
    }
    
    func testResponseDataToFailDueToBuilderError() {
        let caller = URLRequestCaller(
            decoder: decoder,
            getDataPublisher: { _ in
                Just((data: .init(), response: .withStatus(200)))
                    .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                    .eraseToAnyPublisher()
            }
        )

        let builder = URLRequestBuilder(environment: Environment(url: "dad asdas"), endpoint: Environment(url: "dad asdas"), httpMethod: .get)
        let intResponsePublisher: AnyPublisher<Int, NetworkingError> = caller.call(builder: builder)
        intResponsePublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .buildingURL:
                            break
                        default:
                            XCTFail("A wrong error is thrown. Expected NetworkingError.buildingURL, got \(error).")
                        }
                    case .finished:
                        XCTFail("Expected NetworkingError.buildingURL, got .finished completion.")
                    }
                },
                receiveValue: { data in XCTFail("Expected NetworkingError.buildingURL, got \(data).") }
            )
            .store(in: &cancellables)
    }
}

private extension URLRequestCallerTests {
    struct TestEncodable: Codable {
        let name: String
        let age: Int
    }
    
    struct Environment: URLProviding {
        var url: String = "https://google.com"
    }
}

private extension URLResponse {
    static func withStatus(_ status: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://google.com")!,
            statusCode: status,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
