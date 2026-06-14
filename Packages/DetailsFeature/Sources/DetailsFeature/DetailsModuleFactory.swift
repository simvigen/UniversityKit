import DomainKit
import UIKit

public enum DetailsModuleFactory {
  /// Builds the VIPER stack for the details screen.
  ///
  /// `university` is the item handed over from Listing — Details performs
  /// no API call of its own. `output` (the composition root) handles the
  /// Refresh button by delegating back to the listing flow.
  @MainActor
  public static func makeModule(
    university: University,
    output: DetailsModuleOutput,
    navigationController: UINavigationController?
  ) -> UIViewController {
    let interactor = DetailsInteractor(output: output)
    let router = DetailsRouter(navigationController: navigationController)
    let presenter = DetailsPresenter(
      university: university,
      interactor: interactor,
      router: router
    )
    return DetailsViewController(presenter: presenter)
  }
}
