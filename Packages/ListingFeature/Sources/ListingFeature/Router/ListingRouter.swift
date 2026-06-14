import DomainKit
import UIKit

/// VIPER Router: pushes onto the shared UINavigationController.
///
/// The Details screen is created through an injected factory so this package
/// stays decoupled from DetailsFeature; the composition root supplies it.
@MainActor
public final class ListingRouter: ListingRouting {
  public typealias DetailsScreenFactory = (University) -> UIViewController
  
  private weak var navigationController: UINavigationController?
  private let detailsScreenFactory: DetailsScreenFactory
  
  public init(
    navigationController: UINavigationController,
    detailsScreenFactory: @escaping DetailsScreenFactory
  ) {
    self.navigationController = navigationController
    self.detailsScreenFactory = detailsScreenFactory
  }
  
  public func showDetails(for university: University) {
    navigationController?.pushViewController(
      detailsScreenFactory(university),
      animated: true
    )
  }
}
