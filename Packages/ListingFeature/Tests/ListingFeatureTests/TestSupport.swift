import DomainKit
import Foundation
@testable import ListingFeature

extension University {
  static func fixture(
    name: String = "Test University",
    country: String = "United Arab Emirates"
  ) -> University {
    University(
      name: name,
      country: country,
      alphaTwoCode: "AE",
      stateProvince: nil,
      domains: ["test.ac.ae"],
      webPages: ["http://www.test.ac.ae"]
    )
  }
}

struct StubError: LocalizedError, Equatable {
  var errorDescription: String? { "Stub failure" }
}

final class ListingInteractorMock: ListingInteractorProtocol, @unchecked Sendable {
  var loadResult: Result<UniversitiesLoadResult, Error> = .success(
    UniversitiesLoadResult(universities: [], origin: .remote)
  )
  var refreshResult: Result<[University], Error> = .success([])
  private(set) var loadCallCount = 0
  private(set) var refreshCallCount = 0
  
  func loadUniversities() async throws -> UniversitiesLoadResult {
    loadCallCount += 1
    return try loadResult.get()
  }
  
  func refreshUniversities() async throws -> [University] {
    refreshCallCount += 1
    return try refreshResult.get()
  }
}

@MainActor
final class ListingRouterMock: ListingRouting {
  private(set) var shownDetails: [University] = []
  
  func showDetails(for university: University) {
    shownDetails.append(university)
  }
}
