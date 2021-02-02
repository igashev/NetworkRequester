/// Use this object when no data is expected as a response data.
public struct EmptyResponse: Decodable { }

extension EmptyResponse {
    static let emptyJSON = "{}".data(using: .utf8)!
}
