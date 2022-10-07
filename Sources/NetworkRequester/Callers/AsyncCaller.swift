import Foundation

/// Use this object to make network calls and receive decoded values using the new structured concurrency (async/await).
public struct AsyncCaller {
    private let middleware: [Middleware]
    private let urlSession: URLSession
    private let utility: CallerUtility
    
    /// Initialises an object which can make network calls.
    /// - Parameters:
    ///   - urlSession: Session that would make the actual network call.
    ///   - decoder: Decoder that would decode the received data from the network call.
    ///   - middleware: Middleware that is injected in the networking events.
    public init(
        urlSession: URLSession = .shared,
        decoder: JSONDecoder,
        middleware: [Middleware] = []
    ) {
        self.urlSession = urlSession
        self.middleware = middleware
        self.utility = .init(decoder: decoder)
    }
    
    public func call<D: Decodable, DE: DecodableError>(
        using builder: URLRequestBuilder,
        errorType: DE.Type
    ) async throws -> D {
        var request = try builder.build()
        middleware.forEach { $0.onRequest(&request) }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            let tryMap = try utility.checkResponseForErrors(data: data, urlResponse: response, errorType: errorType)
            let tryMap2: D = try utility.decodeIfNecessary(tryMap)
            middleware.forEach { $0.onResponse(data: data, response: response) }
            return tryMap2
        } catch {
            let mappedError = utility.mapError(error)
            middleware.forEach { $0.onError(mappedError, request: request) }
            throw mappedError
        }
    }
    
    public func call<E: DecodableError>(
        using builder: URLRequestBuilder,
        errorType: E.Type
    ) async throws {
        var request = try builder.build()
        middleware.forEach { $0.onRequest(&request) }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            let tryMap = try utility.checkResponseForErrors(data: data, urlResponse: response, errorType: errorType)
            try utility.tryMapEmptyResponseBody(data: tryMap)
            middleware.forEach { $0.onResponse(data: data, response: response) }
        } catch {
            let mappedError = utility.mapError(error)
            middleware.forEach { $0.onError(mappedError, request: request) }
            throw mappedError
        }
    }
}
