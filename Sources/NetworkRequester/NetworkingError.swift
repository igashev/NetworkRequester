import protocol Foundation.LocalizedError
import class Foundation.NSError

/// All possible error that could be thrown.
public enum NetworkingError: Error {
    /// Thrown when constructing URL fails.
    case buildingURL
    
    /// Thrown when encoding request's data fails.
    case encoding(underlyingError: EncodingError)
    
    /// Thrown when decoding response's data fails.
    case decoding(underlyingError: DecodingError)
    
    /// Thrown when the network request fails (returns anything else than 200).
    case networking(status: HTTPStatus, underlyingError: Error?)
    
    /// Thrown when an unknown error is encountered (no other error from the above has been catched).
    /// Optionally forwarding an underlying error if there is one.
    case unknown(underlyingError: Error?)
}

extension NetworkingError: Equatable {
    public static func == (lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        switch (lhs, rhs) {
        case (.buildingURL, .buildingURL):
            return true
        case (.unknown(nil), .unknown(nil)):
            return true
        case (.unknown(.some(let lhs)), .unknown(.some(let rhs))):
            return (lhs as NSError) == (rhs as NSError)
        case (let .networking(lhsStatus, lhsError), let .networking(rhsStatus, rhsError)):
            guard lhsStatus == rhsStatus else { return false }
            return String(reflecting: lhsError) == String(reflecting: rhsError)
        default:
            return false
        }
    }
}
