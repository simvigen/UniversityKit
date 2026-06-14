import DomainKit
import Foundation

/// Wire format of `universities.hipolabs.com/search`.
struct UniversityDTO: Decodable {
  let name: String
  let country: String
  let alphaTwoCode: String?
  let stateProvince: String?
  let domains: [String]?
  let webPages: [String]?
  
  enum CodingKeys: String, CodingKey {
    case name
    case country
    case domains
    case alphaTwoCode = "alpha_two_code"
    // Yes, this one key really is hyphenated in the API.
    case stateProvince = "state-province"
    case webPages = "web_pages"
  }
  
  func toDomain() -> University {
    University(
      name: name,
      country: country,
      alphaTwoCode: alphaTwoCode ?? "",
      stateProvince: stateProvince,
      domains: domains ?? [],
      webPages: webPages ?? []
    )
  }
}
