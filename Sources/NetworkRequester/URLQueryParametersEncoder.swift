import Foundation

/// An object used to transform `Encodable` data models to `[URLQueryItem]`.
enum URLQueryParametersEncoder {
    /// Transforms `Encodable` data model into `[URLQueryItem]`.
    ///
    /// Nested objects are not supported and will be skipped.
    ///
    /// - Parameters:
    ///   - encodable: An encodable data model that would be transformed to query parameters.
    ///   - encoder: An encoder that would do the transformation of the data model.
    /// - Throws: `NetworkingError.buildingURL` if encoding fails.
    /// - Returns: Transformed encodable data model into `[URLQueryItem]` or `[]` if the encodable object is not a `[String: Any]`.
    static func encode<E: Encodable>(encodable: E, encoder: JSONEncoder = .init()) throws -> [URLQueryItem] {
        do {
            let data = try encoder.encode(encodable)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let dictionary = json as? [String: Any] else {
                return []
            }
            
            return dictionary.compactMap { element in
                if element.value is Dictionary<AnyHashable, Any> {
                    print("🚨 Nested objects are not supported and will be skipped. \(#function)")
                    return nil
                } else {
                    return URLQueryItem(name: element.key, value: String(describing: element.value))
                }
            }
        } catch {
            throw NetworkingError.buildingURL
        }
    }
}
