/// Represents an HTTP method of a request.
public enum HTTPMethod {
    case get, post, put, delete, patch
}

// MARK: - CustomStringConvertible

extension HTTPMethod: CustomStringConvertible {
    public var description: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        case .patch:
            return "PATCH"
        }
    }
}
