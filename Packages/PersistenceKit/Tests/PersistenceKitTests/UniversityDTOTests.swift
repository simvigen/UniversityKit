import XCTest
@testable import PersistenceKit

final class UniversityDTOTests: XCTestCase {
  func test_decodesRealWorldPayload() throws {
    let json = Data("""
        [
            {
                "name": "Abu Dhabi University",
                "country": "United Arab Emirates",
                "alpha_two_code": "AE",
                "state-province": "Abu Dhabi",
                "domains": ["adu.ac.ae"],
                "web_pages": ["http://www.adu.ac.ae/"]
            },
            {
                "name": "Ajman University",
                "country": "United Arab Emirates",
                "alpha_two_code": "AE",
                "state-province": null,
                "domains": ["ajman.ac.ae"],
                "web_pages": ["http://www.ajman.ac.ae/"]
            }
        ]
        """.utf8)
    
    let dtos = try JSONDecoder().decode([UniversityDTO].self, from: json)
    
    XCTAssertEqual(dtos.count, 2)
    XCTAssertEqual(dtos[0].stateProvince, "Abu Dhabi")
    XCTAssertNil(dtos[1].stateProvince)
    
    let university = dtos[0].toDomain()
    XCTAssertEqual(university.name, "Abu Dhabi University")
    XCTAssertEqual(university.alphaTwoCode, "AE")
    XCTAssertEqual(university.domains, ["adu.ac.ae"])
    XCTAssertEqual(university.webPages, ["http://www.adu.ac.ae/"])
  }
  
  func test_missingOptionalFields_mapToSafeDefaults() throws {
    let json = Data("""
        [{"name": "Minimal University", "country": "Nowhere"}]
        """.utf8)
    
    let university = try JSONDecoder()
      .decode([UniversityDTO].self, from: json)[0]
      .toDomain()
    
    XCTAssertEqual(university.name, "Minimal University")
    XCTAssertEqual(university.alphaTwoCode, "")
    XCTAssertNil(university.stateProvince)
    XCTAssertEqual(university.domains, [])
    XCTAssertEqual(university.webPages, [])
  }
}
