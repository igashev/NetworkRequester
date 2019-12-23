import Foundation

extension URLRequest {
    mutating func addHeader(_ header: HTTPHeader) {
        addValue(header.value, forHTTPHeaderField: header.field)
    }
}
