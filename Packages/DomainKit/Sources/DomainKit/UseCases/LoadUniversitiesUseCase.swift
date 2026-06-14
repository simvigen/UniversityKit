import Foundation

/// Where a successful load got its data from.
public enum DataOrigin: Equatable, Sendable {
  case remote
  case cache
}

/// Result of a load: the universities plus the origin, so the UI can flag stale data.
public struct UniversitiesLoadResult: Equatable, Sendable {
  public let universities: [University]
  public let origin: DataOrigin
  
  public init(universities: [University], origin: DataOrigin) {
    self.universities = universities
    self.origin = origin
  }
}

/// Loads universities remote-first, falling back to the local cache when the API fails.
public protocol LoadUniversitiesUseCase: Sendable {
  func execute(country: String) async throws -> UniversitiesLoadResult
}

public struct DefaultLoadUniversitiesUseCase: LoadUniversitiesUseCase {
  private let repository: UniversityRepository
  
  public init(repository: UniversityRepository) {
    self.repository = repository
  }
  
  /// Tries the API (which also refreshes the cache); on failure serves cached data
  /// if there is any, otherwise rethrows the original API error.
  public func execute(country: String) async throws -> UniversitiesLoadResult {
    do {
      let fresh = try await repository.fetchAndCacheUniversities(country: country)
      return UniversitiesLoadResult(universities: fresh.normalizedForPresentation(), origin: .remote)
    } catch {
      guard
        let cached = try? await repository.cachedUniversities(country: country),
        !cached.isEmpty
      else {
        throw error
      }
      return UniversitiesLoadResult(universities: cached.normalizedForPresentation(), origin: .cache)
    }
  }
}
