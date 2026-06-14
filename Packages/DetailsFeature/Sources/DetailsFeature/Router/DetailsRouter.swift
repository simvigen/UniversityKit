import UIKit

/// VIPER Router for the details screen.
@MainActor
public final class DetailsRouter: DetailsRouting {
  private weak var navigationController: UINavigationController?
  
  public init(navigationController: UINavigationController?) {
    self.navigationController = navigationController
  }
  
  public func closeDetails() {
    navigationController?.popViewController(animated: true)
  }
}
