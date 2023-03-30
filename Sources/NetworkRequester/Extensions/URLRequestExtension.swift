import Foundation

public extension URLRequest {
    mutating func addHeader(_ header: HTTPHeader) {
        addValue(header.value, forHTTPHeaderField: header.name)
    }
    
    mutating func addHeaders<T: Sequence>(_ headers: T) where T.Element == HTTPHeader {
        headers.forEach { addHeader($0) }
    }
}
