import CoreData
import DomainKit
import Foundation

/// Core Data representation of a cached university.
@objc(UniversityRecord)
final class UniversityRecord: NSManagedObject {
  @NSManaged var id: String
  @NSManaged var name: String
  @NSManaged var country: String
  /// Normalized country the row was fetched for; the cache key.
  @NSManaged var countryQuery: String
  @NSManaged var alphaTwoCode: String
  @NSManaged var stateProvince: String?
  @NSManaged var domainsData: Data?
  @NSManaged var webPagesData: Data?
  
  static let entityName = "UniversityRecord"
  
  /// Programmatic schema — the package's single source of truth for the model.
  static func entityDescription() -> NSEntityDescription {
    let entity = NSEntityDescription()
    entity.name = entityName
    entity.managedObjectClassName = NSStringFromClass(UniversityRecord.self)
    entity.properties = [
      attribute(name: "id", type: .stringAttributeType),
      attribute(name: "name", type: .stringAttributeType),
      attribute(name: "country", type: .stringAttributeType),
      attribute(name: "countryQuery", type: .stringAttributeType),
      attribute(name: "alphaTwoCode", type: .stringAttributeType),
      attribute(name: "stateProvince", type: .stringAttributeType, isOptional: true),
      attribute(name: "domainsData", type: .binaryDataAttributeType, isOptional: true),
      attribute(name: "webPagesData", type: .binaryDataAttributeType, isOptional: true)
    ]
    return entity
  }
  
  private static func attribute(
    name: String,
    type: NSAttributeType,
    isOptional: Bool = false
  ) -> NSAttributeDescription {
    let attribute = NSAttributeDescription()
    attribute.name = name
    attribute.attributeType = type
    attribute.isOptional = isOptional
    return attribute
  }
}

// MARK: - Domain mapping

extension UniversityRecord {
  func populate(from university: University, countryQuery: String) {
    id = university.id
    name = university.name
    country = university.country
    self.countryQuery = countryQuery
    alphaTwoCode = university.alphaTwoCode
    stateProvince = university.stateProvince
    domainsData = Self.encode(university.domains)
    webPagesData = Self.encode(university.webPages)
  }
  
  func toDomain() -> University {
    University(
      name: name,
      country: country,
      alphaTwoCode: alphaTwoCode,
      stateProvince: stateProvince,
      domains: Self.decode(domainsData),
      webPages: Self.decode(webPagesData)
    )
  }
  
  private static func encode(_ values: [String]) -> Data? {
    try? JSONEncoder().encode(values)
  }
  
  private static func decode(_ data: Data?) -> [String] {
    guard let data else { return [] }
    return (try? JSONDecoder().decode([String].self, from: data)) ?? []
  }
}
