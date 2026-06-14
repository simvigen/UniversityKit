import DomainKit
import Foundation

/// Callback into the flow that owns Details. Implemented by the composition
/// root, which forwards the request to the Listing module — Details never
/// touches the network or persistence layers.
@MainActor
public protocol DetailsModuleOutput: AnyObject {
  /// Asks the owning flow to refresh the data set; returns the updated
  /// counterpart of `university`, or nil when it no longer exists.
  func detailsDidRequestRefresh(for university: University) async throws -> University?
}

/// Navigation requests the Details module can make.
@MainActor
public protocol DetailsRouting: AnyObject {
  func closeDetails()
}
