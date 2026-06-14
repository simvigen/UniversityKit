import DomainKit
import UIKit

/// Assembled listing module: the screen plus its externally callable input.
public struct ListingModule {
  public let viewController: UIViewController
  /// Held weakly by callers; it is retained by the view controller's stack.
  public let input: ListingModuleInput
}

public enum ListingModuleFactory {
  /// Builds the VIPER stack for the listing screen.
  @MainActor
  public static func makeModule(
    country: String,
    loadUniversitiesUseCase: LoadUniversitiesUseCase,
    refreshUniversitiesUseCase: RefreshUniversitiesUseCase,
    router: ListingRouting
  ) -> ListingModule {
    let interactor = ListingInteractor(
      country: country,
      loadUniversitiesUseCase: loadUniversitiesUseCase,
      refreshUniversitiesUseCase: refreshUniversitiesUseCase
    )
    let presenter = ListingPresenter(interactor: interactor, router: router)
    let viewController = ListingViewController(presenter: presenter)
    return ListingModule(viewController: viewController, input: presenter)
  }
}
