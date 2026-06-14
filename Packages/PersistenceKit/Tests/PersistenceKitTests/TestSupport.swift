import DomainKit
import Foundation
import NetworkKit
@testable import PersistenceKit

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

final class UniversityRemoteDataSourceMock: UniversityRemoteDataSource, @unchecked Sendable {
  var result: Result<[University], Error> = .success([])
  private(set) var requestedCountries: [String] = []
  
  func fetchUniversities(country: String) async throws -> [University] {
    requestedCountries.append(country)
    return try result.get()
  }
}

final class NetworkClientMock: NetworkClient, @unchecked Sendable {
  var result: Result<Data, Error> = .success(Data())
  private(set) var receivedEndpoints: [Endpoint] = []
  
  func data(for endpoint: Endpoint) async throws -> Data {
    receivedEndpoints.append(endpoint)
    return try result.get()
  }
}
