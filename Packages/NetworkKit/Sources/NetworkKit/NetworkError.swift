import Foundation

public enum NetworkError: Error {
  /// The endpoint could not be turned into a valid URLRequest.
  case invalidRequest
  /// The transport layer failed (offline, timeout, DNS, …).
  case transport(URLError)
  /// The server response was not an HTTP response.
  case invalidResponse
  /// The server answered outside the 2xx range.
  case unacceptableStatus(code: Int)
  /// The payload could not be decoded into the expected type.
  case decoding(Error)
}

extension NetworkError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .invalidRequest:
      return "The request could not be created."
    case .transport(let urlError):
      switch urlError.code {
      case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
        return "You appear to be offline. Check your connection and try again."
      case .timedOut:
        return "The request timed out. Please try again."
      default:
        return "A network error occurred. Please try again."
      }
    case .invalidResponse:
      return "The server returned an unexpected response."
    case .unacceptableStatus(let code):
      return "The server returned an error (code \(code))."
    case .decoding:
      return "The server response could not be read."
    }
  }
}
