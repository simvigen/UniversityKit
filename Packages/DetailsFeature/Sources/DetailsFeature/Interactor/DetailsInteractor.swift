import DomainKit
import Foundation

public enum DetailsError: LocalizedError {
  case refreshUnavailable
  
  public var errorDescription: String? {
    switch self {
    case .refreshUnavailable:
      return "Refresh is currently unavailable."
    }
  }
}

/// VIPER Interactor boundary for the details screen.
@MainActor
public protocol DetailsInteractorProtocol: AnyObject {
  /// Refreshes the data set upstream and returns the updated item, if still present.
  func refresh(current university: University) async throws -> University?
}

/// Details owns no data operations of its own: its single "use case" is
/// delegated upstream through the module output, keeping this feature free
/// of any network/persistence knowledge.
@MainActor
public final class DetailsInteractor: DetailsInteractorProtocol {
  private weak var output: DetailsModuleOutput?
  
  public init(output: DetailsModuleOutput) {
    self.output = output
  }
  
  public func refresh(current university: University) async throws -> University? {
    guard let output else {
      throw DetailsError.refreshUnavailable
    }
    return try await output.detailsDidRequestRefresh(for: university)
  }
}
