import DomainKit
import XCTest
@testable import PersistenceKit

final class CoreDataUniversityLocalDataSourceTests: XCTestCase {
  private var sut: CoreDataUniversityLocalDataSource!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    sut = CoreDataUniversityLocalDataSource(stack: try CoreDataStack(store: .inMemory))
  }
  
  func test_replaceAndFetch_roundTripsAllFields() async throws {
    let university = University.fixture(name: "Abu Dhabi University", stateProvince: "Abu Dhabi")
    
    try await sut.replaceUniversities([university], forCountry: "United Arab Emirates")
    let cached = try await sut.universities(forCountry: "United Arab Emirates")
    
    XCTAssertEqual(cached, [university])
  }
  
  func test_replace_discardsPreviousRows() async throws {
    try await sut.replaceUniversities(
      [.fixture(name: "Old University")],
      forCountry: "United Arab Emirates"
    )
    try await sut.replaceUniversities(
      [.fixture(name: "New University")],
      forCountry: "United Arab Emirates"
    )
    
    let cached = try await sut.universities(forCountry: "United Arab Emirates")
    
    XCTAssertEqual(cached.map(\.name), ["New University"])
  }
  
  func test_cacheIsIsolatedPerCountry() async throws {
    try await sut.replaceUniversities([.fixture(name: "UAE University")], forCountry: "United Arab Emirates")
    try await sut.replaceUniversities([.fixture(name: "FR University", country: "France")], forCountry: "France")
    
    let uae = try await sut.universities(forCountry: "United Arab Emirates")
    let france = try await sut.universities(forCountry: "France")
    
    XCTAssertEqual(uae.map(\.name), ["UAE University"])
    XCTAssertEqual(france.map(\.name), ["FR University"])
  }
  
  func test_countryKeyIsCaseInsensitive() async throws {
    try await sut.replaceUniversities([.fixture()], forCountry: "United Arab Emirates")
    
    let cached = try await sut.universities(forCountry: "united arab emirates")
    
    XCTAssertEqual(cached.count, 1)
  }
}
