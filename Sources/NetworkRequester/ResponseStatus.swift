public enum ResponseStatus {
    case success
    case redirection
    case unauthorized
    case accessRestricted
    case client
    case server
    case unknown
    
    init(statusCode: Int) {
        switch statusCode {
        case 200..<300:
            self = .success
        case 300..<400:
            self = .redirection
        case 401:
            self = .unauthorized
        case 403:
            self = .accessRestricted
        case 400..<500:
            self = .client
        case 500..<600:
            self = .server
        default:
            self = .unknown
        }
    }
}
