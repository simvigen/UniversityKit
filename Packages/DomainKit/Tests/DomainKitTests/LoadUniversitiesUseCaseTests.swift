import XCTest
@testable import DomainKit

final class LoadUniversitiesUseCaseTests: XCTestCase {
  private var repository: UniversityRepositoryMock!
  private var sut: DefaultLoadUniversitiesUseCase!
  
  override func setUp() {
    super.setUp()
    repository = UniversityRepositoryMock()
    sut = DefaultLoadUniversitiesUseCase(repository: repository)
  }
  
  func test_remoteSuccess_returnsRemoteOrigin() async throws {
    repository.fetchResult = .success([.fixture(name: "A University")])
    
    let result = try await sut.execute(country: "United Arab Emirates")
    
    XCTAssertEqual(result.origin, .remote)
    XCTAssertEqual(result.universities.map(\.name), ["A University"])
    XCTAssertEqual(repository.cachedCallCount, 0)
  }
  
  func test_remoteSuccess_sortsAndDeduplicates() async throws {
    repository.fetchResult = .success([
      .fixture(name: "Zayed University"),
      .fixture(name: "Ajman University"),
      .fixture(name: "Zayed University")
    ])
    
    let result = try await sut.execute(country: "United Arab Emirates")
    
    XCTAssertEqual(result.universities.map(\.name), ["Ajman University", "Zayed University"])
  }
  
  func test_remoteFailure_withCachedData_returnsCacheOrigin() async throws {
    repository.fetchResult = .failure(StubError())
    repository.cachedResult = .success([.fixture(name: "Cached University")])
    
    let result = try await sut.execute(country: "United Arab Emirates")
    
    XCTAssertEqual(result.origin, .cache)
    XCTAssertEqual(result.universities.map(\.name), ["Cached University"])
  }
  
  func test_remoteFailure_withEmptyCache_throwsOriginalError() async {
    repository.fetchResult = .failure(StubError())
    repository.cachedResult = .success([])
    
    do {
      _ = try await sut.execute(country: "United Arab Emirates")
      XCTFail("Expected the original remote error to be rethrown")
    } catch {
      XCTAssertEqual(error as? StubError, StubError())
    }
  }
  
  func test_remoteFailure_withCacheFailure_throwsOriginalError() async {
    repository.fetchResult = .failure(StubError())
    repository.cachedResult = .failure(URLError(.cannotOpenFile))
    
    do {
      _ = try await sut.execute(country: "United Arab Emirates")
      XCTFail("Expected the original remote error to be rethrown")
    } catch {
      XCTAssertEqual(error as? StubError, StubError())
    }
  }
}
