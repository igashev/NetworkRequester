import protocol Foundation.LocalizedError

public enum NetworkingError: LocalizedError {
    case responseDecodingFailure(error: DecodingError)
    case failure(HTTPStatus)
    case unknown
}
