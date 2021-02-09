import Foundation

public struct URLQueryParameters {
    public let items: () throws -> [URLQueryItem]
    
    
    public init<E: Encodable>(encodable: E, encoder: JSONEncoder = .init()) {
        self.items = { try URLQueryParametersEncoder.encode(encodable: encodable, encoder: encoder) }
    }
    
    public init(queryItems: [URLQueryItem]) {
        self.items = { queryItems }
    }
}
