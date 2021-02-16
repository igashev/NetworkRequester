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
            decoder: decoder, getDataPublisher: { [encodedData] _ in
                Just((encodedData, .success))
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
    
    func testCallFails() {
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
    
    func testResponseToBeIntButGotEmpty() {
        let caller = URLRequestCaller(decoder: decoder) { _ in
            Just((data: .init(), response: .success))
                .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                .eraseToAnyPublisher()
        }
        
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
        let caller = URLRequestCaller(decoder: decoder) { [encodedData] _ in
            Just((data: encodedData, response: .success))
                .setFailureType(to: URLRequestCaller.AnyURLSessionDataPublisher.Failure.self)
                .eraseToAnyPublisher()
        }
        
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
}

private extension URLRequestCallerTests {
    struct TestEncodable: Codable {
        let name: String
        let age: Int
    }
}

private extension URLResponse {
    static var success: HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://google.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
