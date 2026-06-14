import Foundation

/// Default `NetworkClient` backed by URLSession with async/await.
public struct URLSessionNetworkClient: NetworkClient {
  private let baseURL: URL
  private let session: URLSession
  
  public init(baseURL: URL, session: URLSession = .shared) {
    self.baseURL = baseURL
    self.session = session
  }
  
  public func data(for endpoint: Endpoint) async throws -> Data {
    let request = try endpoint.urlRequest(relativeTo: baseURL)
    
    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await session.data(for: request)
    } catch let urlError as URLError {
      throw NetworkError.transport(urlError)
    } catch {
      throw NetworkError.transport(URLError(.unknown))
    }
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.invalidResponse
    }
    guard (200..<300).contains(httpResponse.statusCode) else {
      throw NetworkError.unacceptableStatus(code: httpResponse.statusCode)
    }
    return data
  }
}
