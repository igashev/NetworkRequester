import Foundation

public struct URLQueryParameters {
    public let items: () throws -> [URLQueryItem]
    
    
    public init<E: Encodable>(encodable: E) {
        self.items = { try URLQueryParametersEncoder.encode(encodable: encodable) }
    }
    
    public init(queryItems: [URLQueryItem]) {
        self.items = { queryItems }
    }
}
