import Foundation

/// Gives the ability to plug into the `call` mechanism of `URLRequestBuilder` to perform side effects
public protocol Middleware {
    /// Called when a request starts execution.
    /// - Parameter request: The request that is about to be executed. Possible to modify.
    func onRequest(_ request: inout URLRequest) async throws
    
    /// Called when a request succeeds..
    /// - Parameters:
    ///   - data: The response's raw data from the request that has succeeded.
    ///   - response: The actual response from the request that has succeeded.
    func onResponse(data: Data, response: URLResponse)
    
    /// Called when a request fails.
    /// - Parameters:
    ///   - error: The error from the request that has failed.
    ///   - request: The actual request that has failed.
    func onError(_ error: NetworkingError, request: URLRequest?)
}

public extension Middleware {
    func onRequest(_ request: inout URLRequest) async throws { }
    func onResponse(data: Data, response: URLResponse) { }
    func onError(_ error: NetworkingError, request: URLRequest?) { }
}
