import XCTest
@testable import DomainKit

final class RefreshUniversitiesUseCaseTests: XCTestCase {
  private var repository: UniversityRepositoryMock!
  private var sut: DefaultRefreshUniversitiesUseCase!
  
  override func setUp() {
    super.setUp()
    repository = UniversityRepositoryMock()
    sut = DefaultRefreshUniversitiesUseCase(repository: repository)
  }
  
  func test_success_returnsNormalizedList() async throws {
    repository.fetchResult = .success([
      .fixture(name: "Zayed University"),
      .fixture(name: "Ajman University")
    ])
    
    let universities = try await sut.execute(country: "United Arab Emirates")
    
    XCTAssertEqual(universities.map(\.name), ["Ajman University", "Zayed University"])
  }
  
  func test_failure_neverFallsBackToCache() async {
    repository.fetchResult = .failure(StubError())
    repository.cachedResult = .success([.fixture(name: "Cached University")])
    
    do {
      _ = try await sut.execute(country: "United Arab Emirates")
      XCTFail("Expected refresh to rethrow the remote error")
    } catch {
      XCTAssertEqual(error as? StubError, StubError())
      XCTAssertEqual(repository.cachedCallCount, 0)
    }
  }
}
