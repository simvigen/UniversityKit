import XCTest
@testable import PersistenceKit

final class HipolabsUniversityRemoteDataSourceTests: XCTestCase {
  func test_buildsSearchEndpointAndMapsDTOs() async throws {
    let client = NetworkClientMock()
    client.result = .success(Data("""
        [{"name": "Abu Dhabi University", "country": "United Arab Emirates", "alpha_two_code": "AE"}]
        """.utf8))
    let sut = HipolabsUniversityRemoteDataSource(client: client)
    
    let universities = try await sut.fetchUniversities(country: "United Arab Emirates")
    
    XCTAssertEqual(universities.map(\.name), ["Abu Dhabi University"])
    XCTAssertEqual(client.receivedEndpoints.count, 1)
    XCTAssertEqual(client.receivedEndpoints[0].path, "search")
    XCTAssertEqual(
      client.receivedEndpoints[0].queryItems,
      [URLQueryItem(name: "country", value: "United Arab Emirates")]
    )
  }
}
