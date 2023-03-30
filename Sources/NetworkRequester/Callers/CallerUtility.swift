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
            throw NetworkingError.unknown(underlyingError: try? decoder.decode(DE.self, from: data))
        }

        guard status.isSuccess else {
            throw NetworkingError.networking(
                status: status,
                underlyingError: try? decoder.decode(DE.self, from: data)
            )
        }

        return data
    }
    
    /// Maps the response's error to the more contextual `NetworkingError` providing the underlying error as well
    /// for further clarification.
    /// - Parameter error: The thrown error.
    /// - Returns: The more contextual `NetworkingError`.
    func mapError(_ error: Error) -> NetworkingError {
        switch error {
        case let decodingError as DecodingError:
            return NetworkingError.decoding(underlyingError: decodingError)
        case let networkingError as NetworkingError:
            return networkingError
        default:
            return .unknown(underlyingError: error)
        }
    }
    
    /// Makes sure that the response's data is empty. This is useful when empty response data is expected.
    /// Throws `DecodingError.dataCorrupted`when data is not empty.
    /// - Parameter data: The data to be checked for emptiness.
    func tryMapEmptyResponseBody(data: Data) throws {
        guard !data.isEmpty else {
            return
        }

        let context = DecodingError.Context(codingPath: [], debugDescription: "Void expects empty body.")
        throw DecodingError.dataCorrupted(context)
    }
    
    /// Decodes data to the provided generic parameter using a `JSONDecoder`.
    /// In cases where `D` is `Data` return the raw data, instead of attempting to decode it. Otherwise - run through the decoder.
    /// - Parameter data: Data to decode.
    /// - Returns: Returns `Data` when the the generic is `Data` or any other `Decodable` that is run through the decoder.
    func decodeIfNecessary<D: Decodable>(_ data: Data) throws -> D {
        if let data = data as? D {
            return data
        } else {
            return try decoder.decode(D.self, from: data)
        }
    }
}
