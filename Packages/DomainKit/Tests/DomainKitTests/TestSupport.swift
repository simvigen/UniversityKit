import Foundation
@testable import DomainKit

extension University {
  static func fixture(
    name: String = "Test University",
    country: String = "United Arab Emirates",
    stateProvince: String? = nil
  ) -> University {
    University(
      name: name,
      country: country,
      alphaTwoCode: "AE",
      stateProvince: stateProvince,
      domains: ["test.ac.ae"],
      webPages: ["http://www.test.ac.ae"]
    )
  }
}

struct StubError: Error, Equatable {}

final class UniversityRepositoryMock: UniversityRepository, @unchecked Sendable {
  var fetchResult: Result<[University], Error> = .success([])
  var cachedResult: Result<[University], Error> = .success([])
  private(set) var fetchCallCount = 0
  private(set) var cachedCallCount = 0
  
  func fetchAndCacheUniversities(country: String) async throws -> [University] {
    fetchCallCount += 1
    return try fetchResult.get()
  }
  
  func cachedUniversities(country: String) async throws -> [University] {
    cachedCallCount += 1
    return try cachedResult.get()
  }
}
