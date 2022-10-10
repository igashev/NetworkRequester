import Foundation

/// Use this object to make network calls and receive decoded values using the new structured concurrency (async/await).
public struct AsyncCaller {
    private let middlewares: [Middleware]
    private let urlSession: URLSession
    private let utility: CallerUtility
    
    private var middlewaresAsyncStream: AsyncThrowingStream<Middleware, Error> {
        .init { continuation in
            middlewares.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }
    
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
        self.middlewares = middleware
        self.utility = .init(decoder: decoder)
    }
    
    public func call<D: Decodable, DE: DecodableError>(
        using builder: URLRequestBuilder,
        errorType: DE.Type
    ) async throws -> D {
        var mutableRequest = try builder.build()
        try await runMiddlewaresOnRequest(request: &mutableRequest)
        
        do {
            let (data, response) = try await urlSession.data(for: mutableRequest)
            let tryMap = try utility.checkResponseForErrors(data: data, urlResponse: response, errorType: errorType)
            let tryMap2: D = try utility.decodeIfNecessary(tryMap)
            middlewares.forEach { $0.onResponse(data: data, response: response) }
            return tryMap2
        } catch {
            let mappedError = utility.mapError(error)
            middlewares.forEach { $0.onError(mappedError, request: mutableRequest) }
            throw mappedError
        }
    }
    
    public func call<E: DecodableError>(
        using builder: URLRequestBuilder,
        errorType: E.Type
    ) async throws {
        var mutableRequest = try builder.build()
        try await runMiddlewaresOnRequest(request: &mutableRequest)
        
        do {
            let (data, response) = try await urlSession.data(for: mutableRequest)
            let tryMap = try utility.checkResponseForErrors(data: data, urlResponse: response, errorType: errorType)
            try utility.tryMapEmptyResponseBody(data: tryMap)
            middlewares.forEach { $0.onResponse(data: data, response: response) }
        } catch {
            let mappedError = utility.mapError(error)
            middlewares.forEach { $0.onError(mappedError, request: mutableRequest) }
            throw mappedError
        }
    }
    
    private func runMiddlewaresOnRequest(request: inout URLRequest) async throws {
        for try await middleware in middlewaresAsyncStream {
            try await middleware.onRequest(&request)
        }
    }
}
