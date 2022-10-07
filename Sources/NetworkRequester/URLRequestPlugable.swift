import Foundation

/// Gives the ability to plug into the `call` mechanizm of `URLRequestBuilder` to perform side effects
public protocol URLRequestPlugable {
    /// Called when a request start execution
    func onRequest(_ request: URLRequest)
    
    /// Called with the raw data & respnse of from the request
    func onResponse(data: Data, response: URLResponse)
    
    /// Called with the decoded error of the request
    func onError(_ error: NetworkingError, request: URLRequest?)
}

public extension URLRequestPlugable {
    func onRequest(_ _: URLRequest) { }
    func onResponse(data _: Data, response _: URLResponse) { }
    func onError(_: NetworkingError, request: URLRequest?) { }
}
