public struct HTTPHeader {
    public let name: String
    public let value: String
    
    /// A JSON HTTP header that has a name of `Content-Type` and a value of `application/json`
    public static let json = Self(name: "Content-Type", value: "application/json")
    
    /// An authorization HTTP header that has a name of `Authorization` and a value of `Bearer \(token)`
    /// - Parameter token: A bearer token to be set as a value.
    /// - Returns: An `HTTPHeader` instance with authorization name and a token value.
    public static func authorization(bearerToken token: String) -> Self {
        authorization(token: "Bearer \(token)")
    }
    
    public static func authorization(token: String) -> Self {
        .init(name: "Authorization", value: token)
    }
}

extension HTTPHeader: Hashable { }
