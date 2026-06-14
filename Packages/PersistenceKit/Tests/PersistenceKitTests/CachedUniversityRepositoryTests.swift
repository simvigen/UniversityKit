import DomainKit
import XCTest
@testable import PersistenceKit

final class CachedUniversityRepositoryTests: XCTestCase {
  private var remote: UniversityRemoteDataSourceMock!
  private var local: CoreDataUniversityLocalDataSource!
  private var sut: CachedUniversityRepository!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    remote = UniversityRemoteDataSourceMock()
    local = CoreDataUniversityLocalDataSource(stack: try CoreDataStack(store: .inMemory))
    sut = CachedUniversityRepository(remote: remote, local: local)
  }
  
  func test_fetchSuccess_returnsFreshDataAndRefreshesCache() async throws {
    let fresh = [University.fixture(name: "Fresh University")]
    remote.result = .success(fresh)
    
    let fetched = try await sut.fetchAndCacheUniversities(country: "United Arab Emirates")
    let cached = try await sut.cachedUniversities(country: "United Arab Emirates")
    
    XCTAssertEqual(fetched, fresh)
    XCTAssertEqual(cached, fresh)
    XCTAssertEqual(remote.requestedCountries, ["United Arab Emirates"])
  }
  
  func test_fetchSuccess_replacesStaleCache() async throws {
    remote.result = .success([.fixture(name: "Old University")])
    _ = try await sut.fetchAndCacheUniversities(country: "United Arab Emirates")
    
    remote.result = .success([.fixture(name: "New University")])
    _ = try await sut.fetchAndCacheUniversities(country: "United Arab Emirates")
    
    let cached = try await sut.cachedUniversities(country: "United Arab Emirates")
    XCTAssertEqual(cached.map(\.name), ["New University"])
  }
  
  func test_fetchFailure_propagatesErrorAndKeepsCacheIntact() async throws {
    remote.result = .success([.fixture(name: "Cached University")])
    _ = try await sut.fetchAndCacheUniversities(country: "United Arab Emirates")
    
    remote.result = .failure(StubError())
    do {
      _ = try await sut.fetchAndCacheUniversities(country: "United Arab Emirates")
      XCTFail("Expected the remote error to propagate")
    } catch {
      XCTAssertEqual(error as? StubError, StubError())
    }
    
    let cached = try await sut.cachedUniversities(country: "United Arab Emirates")
    XCTAssertEqual(cached.map(\.name), ["Cached University"])
  }
}
