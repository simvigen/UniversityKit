import DomainKit
import Foundation
import NetworkKit

/// Remote source of universities, expressed in domain terms.
public protocol UniversityRemoteDataSource: Sendable {
  func fetchUniversities(country: String) async throws -> [University]
}

/// Talks to the Hipolabs universities API through the generic NetworkKit client
/// and maps wire DTOs into the shared domain model.
public struct HipolabsUniversityRemoteDataSource: UniversityRemoteDataSource {
  private let client: NetworkClient
  
  public init(client: NetworkClient) {
    self.client = client
  }
  
  public func fetchUniversities(country: String) async throws -> [University] {
    let endpoint = Endpoint(
      path: "search",
      queryItems: [URLQueryItem(name: "country", value: country)]
    )
    let dtos = try await client.decode([UniversityDTO].self, from: endpoint)
    return dtos.map { $0.toDomain() }
  }
}
