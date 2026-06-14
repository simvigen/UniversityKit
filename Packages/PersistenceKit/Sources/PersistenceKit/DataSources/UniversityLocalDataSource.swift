import CoreData
import DomainKit
import Foundation

/// Read/write access to the local universities cache.
public protocol UniversityLocalDataSource: Sendable {
  func universities(forCountry country: String) async throws -> [University]
  func replaceUniversities(_ universities: [University], forCountry country: String) async throws
}

public final class CoreDataUniversityLocalDataSource: UniversityLocalDataSource, @unchecked Sendable {
  private let stack: CoreDataStack
  
  public init(stack: CoreDataStack) {
    self.stack = stack
  }
  
  public func universities(forCountry country: String) async throws -> [University] {
    let key = Self.cacheKey(for: country)
    return try await stack.performBackgroundTask { context in
      let request = NSFetchRequest<UniversityRecord>(entityName: UniversityRecord.entityName)
      request.predicate = NSPredicate(format: "countryQuery == %@", key)
      return try context.fetch(request).map { $0.toDomain() }
    }
  }
  
  /// Atomically swaps the cached rows for the country with the fresh set.
  public func replaceUniversities(_ universities: [University], forCountry country: String) async throws {
    let key = Self.cacheKey(for: country)
    try await stack.performBackgroundTask { context in
      let request = NSFetchRequest<UniversityRecord>(entityName: UniversityRecord.entityName)
      request.predicate = NSPredicate(format: "countryQuery == %@", key)
      // Fetch-and-delete (not NSBatchDeleteRequest) so in-memory test stores behave identically.
      for record in try context.fetch(request) {
        context.delete(record)
      }
      for university in universities {
        let record = UniversityRecord(context: context)
        record.populate(from: university, countryQuery: key)
      }
      if context.hasChanges {
        try context.save()
      }
    }
  }
  
  private static func cacheKey(for country: String) -> String {
    country.lowercased()
  }
}
