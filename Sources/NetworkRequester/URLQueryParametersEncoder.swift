import Foundation

public enum URLQueryParametersEncoder {
    public static func encode<E: Encodable>(encodable: E) throws -> [URLQueryItem] {
        do {
            let data = try JSONEncoder().encode(encodable)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let dictionary = json as? [String: Any] else {
                return []
            }
            
            return dictionary.compactMap { element in
                guard element.value is Dictionary<AnyHashable, Any> else {
                    print("🚨 Nested objects are not supported and will be skipped. \(#function)")
                    return nil
                }
                
                return URLQueryItem(name: element.key, value: String(describing: element.value))
                
            }
        } catch {
            throw NetworkingError.buildingURLFailure
        }
    }
}
