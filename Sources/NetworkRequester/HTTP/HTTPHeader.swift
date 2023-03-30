/// Represents an HTTP header of a request.
public struct HTTPHeader: Hashable {
    /// The name of the header.
    public let name: String
    
    /// The value of the header.
    public let value: String
    
    /// Initializes `HTTPHeader` using the provided name and value.
    /// - Parameters:
    ///   - name: The name of the header.
    ///   - value: The value of the header.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

public extension HTTPHeader {
    /// A JSON HTTP header that has a name of `Content-Type` and a value of `application/json`.
    static let json = Self(name: "Content-Type", value: "application/json")
    
    /// An authorization HTTP header that has a name of `Authorization` and a value of `Bearer \(token)`
    /// - Parameter token: A bearer token to be set as a value.
    /// - Returns: An `HTTPHeader` instance with authorization name and a token value.
    static func authorization(bearerToken token: String) -> Self {
        authorization(token: "Bearer \(token)")
    }
    
    /// An authorization HTTP header that has a name of `Authorization` and a value of `token`.
    /// - Parameter token: A token to be set as a value.
    /// - Returns: An `HTTPHeader` instance with authorization name and a token value.
    static func authorization(token: String) -> Self {
        .init(name: "Authorization", value: token)
    }
}
