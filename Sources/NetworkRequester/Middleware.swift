import Foundation

/// Gives the ability to plug into the `call` mechanizm of `URLRequestBuilder` to perform side effects
public protocol Middleware {
    /// Called when a request start execution
    func onRequest(_ request: inout URLRequest) async throws
    
    /// Called with the raw data & respnse of from the request
    func onResponse(data: Data, response: URLResponse)
    
    /// Called with the decoded error of the request
    func onError(_ error: NetworkingError, request: URLRequest?)
}

public extension Middleware {
    func onRequest(_ request: inout URLRequest) async throws { }
    func onResponse(data: Data, response: URLResponse) { }
    func onError(_ error: NetworkingError, request: URLRequest?) { }
}
