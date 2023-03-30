/// Represents an HTTP method of a request. Extend when needed others that are not listed by default.
public struct HTTPMethod: RawRepresentable, Equatable {
    public typealias RawValue = String
    
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

// MARK: - CustomStringConvertible

extension HTTPMethod: CustomStringConvertible {
    public var description: String { rawValue }
}

public extension HTTPMethod {
    static let get = Self(rawValue: "GET")
    static let post = Self(rawValue: "POST")
    static let put = Self(rawValue: "PUT")
    static let delete = Self(rawValue: "DELETE")
    static let patch = Self(rawValue: "PATCH")
}
