import Foundation

/// A wrapper that represents an HTTP body of a request.
public struct HTTPBody {
    /// The encoded data.
    ///
    /// Throws `NetworkingError.encoding(error:)` if encoding fails.
    public let data: () throws -> Data
    
    /// Initializes `HTTPBody` using an encodable data model and an encoder.
    /// - Parameters:
    ///   - encodable: An encodable data model that would be transformed to `Data`.
    ///   - jsonEncoder: An encoder that would do the transformation of the data model.
    public init<T: Encodable>(encodable: T, jsonEncoder: JSONEncoder) {
        self.data = {
            do {
                return try jsonEncoder.encode(encodable)
            } catch let error as EncodingError {
                throw NetworkingError.encoding(error: error)
            }
        }
    }
}
