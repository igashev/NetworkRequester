public struct HTTPHeader {
    public let field: String
    public let value: String
    
    public static let json = Self(field: "Content-Type", value: "application/json")
    
    public static func authorization(withToken token: String) -> Self {
        return Self(field: "Authorization", value: "Bearer \(token)")
    }
}
