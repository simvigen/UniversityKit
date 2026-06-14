import Foundation

/// Abstraction over HTTP transport so data-layer code can be tested without
/// real networking and never depends on URLSession directly.
public protocol NetworkClient: Sendable {
  /// Performs the request described by the endpoint and returns the raw body
  /// after status-code validation.
  func data(for endpoint: Endpoint) async throws -> Data
}

public extension NetworkClient {
  /// Fetches and decodes a JSON payload, normalizing decode failures
  /// into `NetworkError.decoding`.
  func decode<T: Decodable>(
    _ type: T.Type,
    from endpoint: Endpoint,
    using decoder: JSONDecoder = JSONDecoder()
  ) async throws -> T {
    let data = try await data(for: endpoint)
    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw NetworkError.decoding(error)
    }
  }
}
