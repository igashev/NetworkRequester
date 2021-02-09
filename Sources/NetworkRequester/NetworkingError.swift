import protocol Foundation.LocalizedError

public enum NetworkingError: LocalizedError {
    case buildingURL
    case encoding(error: EncodingError)
    case decoding(error: DecodingError)
    case networking(HTTPStatus)
    case unknown
}
