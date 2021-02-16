import Foundation

/// Use this object when no data is expected as a response data.
public struct EmptyResponse: Decodable { }

extension EmptyResponse {
    /// `JSONDecoder` fails when trying to decode empty string so whenever an
    /// `EmptyResponse` is expected the received data is just exchanged with this one.
    static let emptyJSON = Data("{}".utf8)
}
