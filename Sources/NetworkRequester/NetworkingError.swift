import protocol Foundation.LocalizedError

public enum NetworkingError: LocalizedError {
    case buildingURLFailure
    case encodingError(error: EncodingError)
    case decodingFailure(error: DecodingError)
    case failure(HTTPStatus)
    case unknown
}
