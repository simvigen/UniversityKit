import DomainKit
import Foundation

/// Navigation requests the Listing module can make; fulfilled by the Router layer.
@MainActor
public protocol ListingRouting: AnyObject {
  func showDetails(for university: University)
}

/// Entry point other modules (via the composition root) can call into Listing.
/// Details' Refresh button lands here, so the refresh is always executed by the
/// listing flow that owns data loading.
@MainActor
public protocol ListingModuleInput: AnyObject {
  /// Reloads from the API, updating the cache and the listing state.
  /// Returns the fresh list; throws when the API call fails.
  @discardableResult
  func refreshFromExternalTrigger() async throws -> [University]
}
