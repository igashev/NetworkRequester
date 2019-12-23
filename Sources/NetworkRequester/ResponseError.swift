import protocol Foundation.LocalizedError

public enum ResponseError: LocalizedError {
    case noDataReceived, invalidResponseType, responseError(ResponseStatus)
}
