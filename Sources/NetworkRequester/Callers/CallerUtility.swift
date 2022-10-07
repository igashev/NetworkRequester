import Foundation

public typealias DecodableError = Error & Decodable

struct CallerUtility {
    let decoder: JSONDecoder
    
    /// Checks if any errors need to be thrown based on the response
    /// - Parameters:
    ///   - data: The data of the response
    ///   - urlResponse: The URLResponse
    ///   - errorType: An Error type to be decoded from the body in non-success cases
    /// - Throws: `NetworkingError`
    /// - Returns: The data that was passed in
    func checkResponseForErrors<DE: DecodableError>(
        data: Data,
        urlResponse: URLResponse,
        errorType: DE.Type
    ) throws -> Data {
        guard
            let httpResponse = urlResponse as? HTTPURLResponse,
            let status = HTTPStatus(rawValue: httpResponse.statusCode)
        else {
            throw NetworkingError.networking(
                status: .internalServerError,
                error: try? decoder.decode(DE.self, from: data)
            )
        }

        guard status.isSuccess else {
            throw NetworkingError.networking(status: status, error: try? decoder.decode(DE.self, from: data))
        }

        return data
    }
    
    func mapError(_ error: Error) -> NetworkingError {
        switch error {
        case let decodingError as DecodingError:
            return NetworkingError.decoding(error: decodingError)
        case let networkingError as NetworkingError:
            return networkingError
        default:
            return .unknown(error)
        }
    }
    
    func tryMapEmptyResponseBody(data: Data) throws {
        guard !data.isEmpty else {
            return
        }

        let context = DecodingError.Context(codingPath: [], debugDescription: "Void expects empty body.")
        throw DecodingError.dataCorrupted(context)
    }
    
    func decodeIfNecessary<D: Decodable>(_ data: Data) throws -> D {
        // In cases where D is Data, we return the raw data instead of attempting to decode it
        if let data = data as? D {
            return data
        }
        // Otherwise - run through the decoder
        else {
            return try decoder.decode(D.self, from: data)
        }
    }
}
