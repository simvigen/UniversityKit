import Foundation

/// A declarative description of a single API call, resolved against a base URL
/// at request time. Keeps request building in one tested place.
public struct Endpoint: Sendable {
  public var path: String
  public var method: HTTPMethod
  public var queryItems: [URLQueryItem]
  public var headers: [String: String]
  public var body: Data?
  
  public init(
    path: String,
    method: HTTPMethod = .get,
    queryItems: [URLQueryItem] = [],
    headers: [String: String] = [:],
    body: Data? = nil
  ) {
    self.path = path
    self.method = method
    self.queryItems = queryItems
    self.headers = headers
    self.body = body
  }
  
  public func urlRequest(relativeTo baseURL: URL) throws -> URLRequest {
    guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
      throw NetworkError.invalidRequest
    }
    
    let trimmedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
    components.path = components.path.hasSuffix("/")
    ? components.path + trimmedPath
    : components.path + "/" + trimmedPath
    
    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }
    
    guard let url = components.url else {
      throw NetworkError.invalidRequest
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = body
    for (field, value) in headers {
      request.setValue(value, forHTTPHeaderField: field)
    }
    return request
  }
}
