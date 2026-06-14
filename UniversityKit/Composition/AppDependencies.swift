import DomainKit
import Foundation
import NetworkKit
import PersistenceKit
import os

/// Composition root: builds the network + persistence stack once and exposes
/// only domain-level use cases to the feature modules.
final class AppDependencies {
  let loadUniversitiesUseCase: LoadUniversitiesUseCase
  let refreshUniversitiesUseCase: RefreshUniversitiesUseCase
  
  init() {
    let client = URLSessionNetworkClient(baseURL: AppConfiguration.universitiesAPIBaseURL)
    let remote = HipolabsUniversityRemoteDataSource(client: client)
    let local = CoreDataUniversityLocalDataSource(stack: Self.makeCoreDataStack())
    let repository = CachedUniversityRepository(remote: remote, local: local)
    
    loadUniversitiesUseCase = DefaultLoadUniversitiesUseCase(repository: repository)
    refreshUniversitiesUseCase = DefaultRefreshUniversitiesUseCase(repository: repository)
  }
  
  /// A broken on-disk store must not take the app down — degrade to a
  /// session-only in-memory cache and keep the network path fully functional.
  private static func makeCoreDataStack() -> CoreDataStack {
    do {
      return try CoreDataStack()
    } catch {
      Logger(subsystem: "com.Vigen.UniversalKit", category: "App")
        .error("Falling back to in-memory cache: \(error.localizedDescription, privacy: .public)")
      do {
        return try CoreDataStack(store: .inMemory)
      } catch {
        preconditionFailure("In-memory Core Data store failed to load: \(error)")
      }
    }
  }
}
