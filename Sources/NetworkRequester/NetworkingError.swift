import protocol Foundation.LocalizedError

/// All possible error that could be thrown.
public enum NetworkingError: LocalizedError {
    /// Thrown when constructing URL fails.
    case buildingURL
    
    /// Thrown when encoding body's data fails.
    case encoding(error: EncodingError)
    
    /// Thrown when decoding response's data fails.
    case decoding(error: DecodingError)
    
    /// Thrown when the network request fails.
    case networking(HTTPStatus)
    
    /// Thrown when an unknown error is thrown (no other error from the above has been catched).
    case unknown
}
