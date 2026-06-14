import Foundation

/// Forces a fresh API fetch (updating the cache); unlike loading, a refresh
/// never falls back to cached data — failure is reported to the caller.
public protocol RefreshUniversitiesUseCase: Sendable {
  func execute(country: String) async throws -> [University]
}

public struct DefaultRefreshUniversitiesUseCase: RefreshUniversitiesUseCase {
  private let repository: UniversityRepository
  
  public init(repository: UniversityRepository) {
    self.repository = repository
  }
  
  public func execute(country: String) async throws -> [University] {
    try await repository.fetchAndCacheUniversities(country: country).normalizedForPresentation()
  }
}

