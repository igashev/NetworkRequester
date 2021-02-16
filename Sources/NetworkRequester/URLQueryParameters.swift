import Foundation

/// A wrapper used for query parameters. Could be used with an encodable data models or directly with `URLQueryItem`s.
public struct URLQueryParameters {
    /// The final query items.
    ///
    /// Throws `NetworkingError.buildingURL` if transforming items using `JSONEcoder` fails.
    public let items: () throws -> [URLQueryItem]
    
    /// Initializes query parameters using an encodable data model and an encoder.
    ///
    ///```
    ///struct PaginationQuery: Encodable {
    ///     let page: Int
    ///     let per: Int
    ///}
    ///
    ///let paginationQuery = PaginationQuery(page: 10, per: 15)
    ///let queryItems = URLQueryParameters(encodable: paginationQuery, encoder: .init())
    ///// This would finally result in ?page=10&per=15
    ///```
    ///
    /// - Parameters:
    ///   - encodable: An encodable data model that would be transformed to query parameters.
    ///   - encoder: An encoder that would do the transformation of the data model.
    public init<E: Encodable>(encodable: E, encoder: JSONEncoder) {
        self.items = { try URLQueryParametersEncoder.encode(encodable: encodable, encoder: encoder) }
    }
    
    /// Initializes query parameters using regular `URLQueryItem`s.
    /// - Parameter queryItems: Regular query items.
    ///
    ///```
    ///let paginationQuery = [
    ///     URLQueryItem(name: "page", value: "10"),
    ///     URLQueryItem(name: "per", value: "15")
    ///]
    ///let queryItems = URLQueryParameters(queryItems: paginationQuery)
    ///// This would finally result in ?page=10&per=15
    ///```
    public init(queryItems: [URLQueryItem]) {
        self.items = { queryItems }
    }
}
