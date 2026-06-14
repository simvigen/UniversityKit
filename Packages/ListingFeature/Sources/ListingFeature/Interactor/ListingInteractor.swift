import DomainKit
import Foundation

/// VIPER Interactor boundary for the listing screen.
public protocol ListingInteractorProtocol: Sendable {
  func loadUniversities() async throws -> UniversitiesLoadResult
  func refreshUniversities() async throws -> [University]
}

/// Executes domain use cases for the configured country.
public struct ListingInteractor: ListingInteractorProtocol {
  private let country: String
  private let loadUniversitiesUseCase: LoadUniversitiesUseCase
  private let refreshUniversitiesUseCase: RefreshUniversitiesUseCase
  
  public init(
    country: String,
    loadUniversitiesUseCase: LoadUniversitiesUseCase,
    refreshUniversitiesUseCase: RefreshUniversitiesUseCase
  ) {
    self.country = country
    self.loadUniversitiesUseCase = loadUniversitiesUseCase
    self.refreshUniversitiesUseCase = refreshUniversitiesUseCase
  }
  
  public func loadUniversities() async throws -> UniversitiesLoadResult {
    try await loadUniversitiesUseCase.execute(country: country)
  }
  
  public func refreshUniversities() async throws -> [University] {
    try await refreshUniversitiesUseCase.execute(country: country)
  }
}
