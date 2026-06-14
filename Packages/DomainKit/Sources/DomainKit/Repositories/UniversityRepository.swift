import Foundation

/// Domain boundary for university data. Implemented by the data layer
/// (PersistenceKit), consumed by use cases — features never see data sources.
public protocol UniversityRepository: Sendable {
  /// Fetches universities from the remote API and refreshes the local cache on success.
  func fetchAndCacheUniversities(country: String) async throws -> [University]
  
  /// Returns whatever the local cache currently holds for the country (possibly empty).
  func cachedUniversities(country: String) async throws -> [University]
}
