import CoreData
import Foundation

public enum PersistenceError: Error {
  case storeLoadFailed(Error)
  case storeDirectoryUnavailable(Error)
}

/// Owns the Core Data container backing the universities cache.
///
/// The managed object model is built in code (see `UniversityRecord.entityDescription()`),
/// so the package needs no bundled `.xcdatamodeld` resource and tests can spin up
/// in-memory stores against the exact same schema.
public final class CoreDataStack: @unchecked Sendable {
  public enum Store {
    /// SQLite store in Application Support.
    case onDisk(name: String)
    /// Session-only store, used by tests and as a degraded fallback.
    case inMemory
  }
  
  /// A single shared model instance: registering the same NSManagedObject
  /// subclass with multiple models confuses Core Data's class lookup.
  static let model: NSManagedObjectModel = {
    let model = NSManagedObjectModel()
    model.entities = [UniversityRecord.entityDescription()]
    return model
  }()
  
  let container: NSPersistentContainer
  
  public init(store: Store = .onDisk(name: "UniversitiesCache")) throws {
    let container = NSPersistentContainer(name: "UniversitiesCache", managedObjectModel: Self.model)
    
    let description: NSPersistentStoreDescription
    switch store {
    case .onDisk(let name):
      description = NSPersistentStoreDescription(url: try Self.storeURL(name: name))
    case .inMemory:
      description = NSPersistentStoreDescription()
      description.type = NSInMemoryStoreType
    }
    // Load synchronously so a usable (or failed) stack exists right after init.
    description.shouldAddStoreAsynchronously = false
    container.persistentStoreDescriptions = [description]
    
    var loadError: Error?
    container.loadPersistentStores { _, error in
      loadError = error
    }
    if let loadError {
      throw PersistenceError.storeLoadFailed(loadError)
    }
    
    container.viewContext.automaticallyMergesChangesFromParent = true
    self.container = container
  }
  
  /// Runs work on a private background context with async/await semantics.
  func performBackgroundTask<T>(
    _ block: @escaping (NSManagedObjectContext) throws -> T
  ) async throws -> T {
    try await container.performBackgroundTask(block)
  }
  
  private static func storeURL(name: String) throws -> URL {
    do {
      let directory = try FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      return directory.appendingPathComponent("\(name).sqlite")
    } catch {
      throw PersistenceError.storeDirectoryUnavailable(error)
    }
  }
}
