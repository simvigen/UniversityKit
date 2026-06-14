import DomainKit
import Foundation
import os

/// Remote-first repository: a successful API fetch refreshes the cache;
/// the cache is the dedicated read path for offline fallback.
///
/// Lives in PersistenceKit because this is the data layer's composition point
/// of remote + local sources (the "caching repository" of the spec).
public final class CachedUniversityRepository: UniversityRepository {
  private let remote: UniversityRemoteDataSource
  private let local: UniversityLocalDataSource
  private let logger = Logger(subsystem: "com.Vigen.UniversalKit", category: "PersistenceKit")
  
  public init(remote: UniversityRemoteDataSource, local: UniversityLocalDataSource) {
    self.remote = remote
    self.local = local
  }
  
  public func fetchAndCacheUniversities(country: String) async throws -> [University] {
    let fresh = try await remote.fetchUniversities(country: country)
    do {
      try await local.replaceUniversities(fresh, forCountry: country)
    } catch {
      // Serving fresh data matters more than the cache write; next success retries it.
      logger.error("Failed to update universities cache: \(error.localizedDescription, privacy: .public)")
    }
    return fresh
  }
  
  public func cachedUniversities(country: String) async throws -> [University] {
    try await local.universities(forCountry: country)
  }
}
