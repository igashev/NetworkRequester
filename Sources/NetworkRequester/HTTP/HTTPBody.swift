import Foundation

public struct HTTPBody {
    public let data: () throws -> Data
    
    init<T: Encodable>(encodable: T, jsonEncoder: JSONEncoder = .init()) {
        self.data = {
            do {
                return try jsonEncoder.encode(encodable)
            } catch let error as EncodingError {
                throw NetworkingError.encodingError(error: error)
            }
        }
    }
}
