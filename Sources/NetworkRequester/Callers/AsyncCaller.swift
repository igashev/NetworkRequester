import Foundation

/// Use this object to make network calls and receive decoded values using the new structured concurrency (async/await).
///
/// ```
/// struct User: Decodable {
///     let name: String
/// }
///
/// struct BackendError: DecodableError {
///     let errorCode: Int
///     let localizedError: String
/// }
///
/// let requestBuilder = URLRequestBuilder(
///     environment: "https://amazingapi.com",
///     endpoint: "v1/users",
///     httpMethod: .get,
///     httpHeaders: [
///         .json,
///         .authorization(bearerToken: "secretBearerToken")
///     ],
///     httpBody: nil,
///     queryParameters: nil
/// )
///
/// let caller = AsyncCaller(decoder: JSONDecoder())
/// let user: User = try await caller.call(
///     using: requestBuilder,
///     errorType: BackendError.self
/// )
/// ```
public struct AsyncCaller {
    public let urlSession: URLSession
    public let middlewares: [Middleware]
    
    private let utility: CallerUtility
    private var middlewaresOnRequestAsyncStream: AsyncThrowingStream<Middleware, Error> {
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
        middleware: [Middleware] = [],
        decoder: JSONDecoder
    ) {
        self.urlSession = urlSession
        self.middlewares = middleware
        self.utility = .init(decoder: decoder)
    }
    
    public func call<D: Decodable, DE: DecodableError>(
        using builder: URLRequestBuilder,
        errorType: DE.Type
    ) async throws -> D {
        try await call(using: builder.build(), errorType: errorType)
    }
    
    public func call<DE: DecodableError>(
        using builder: URLRequestBuilder,
        errorType: DE.Type
    ) async throws {
        try await call(using: builder.build(), errorType: errorType)
    }
    
    public func call<D: Decodable, DE: DecodableError>(
        using request: URLRequest,
        errorType: DE.Type
    ) async throws -> D {
        var mutableRequest = request
        try await runMiddlewaresOnRequest(request: &mutableRequest)
        
        do {
            let (data, response) = try await urlSession.data(for: mutableRequest)
            let tryMap = try utility.checkResponseForErrors(
                data: data,
                urlResponse: response,
                errorType: errorType
            )
            let tryMap2: D = try utility.decodeIfNecessary(tryMap)
            middlewares.forEach { $0.onResponse(data: data, response: response) }
            return tryMap2
        } catch {
            let mappedError = utility.mapError(error)
            middlewares.forEach { $0.onError(mappedError, request: mutableRequest) }
            throw mappedError
        }
    }
    
    public func call<DE: DecodableError>(
        using request: URLRequest,
        errorType: DE.Type
    ) async throws {
        var mutableRequest = request
        try await runMiddlewaresOnRequest(request: &mutableRequest)
        
        do {
            let (data, response) = try await urlSession.data(for: mutableRequest)
            let tryMap = try utility.checkResponseForErrors(
                data: data,
                urlResponse: response,
                errorType: errorType
            )
            try utility.tryMapEmptyResponseBody(data: tryMap)
            middlewares.forEach { $0.onResponse(data: data, response: response) }
        } catch {
            let mappedError = utility.mapError(error)
            middlewares.forEach { $0.onError(mappedError, request: mutableRequest) }
            throw mappedError
        }
    }
    
    private func runMiddlewaresOnRequest(request: inout URLRequest) async throws {
        guard !middlewares.isEmpty else {
            return
        }
        
        for try await middleware in middlewaresOnRequestAsyncStream {
            try await middleware.onRequest(&request)
        }
    }
}
