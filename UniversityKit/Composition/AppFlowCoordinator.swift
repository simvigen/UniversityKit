import DetailsFeature
import DomainKit
import ListingFeature
import UIKit

enum AppFlowError: LocalizedError {
  case listingUnavailable
  
  var errorDescription: String? {
    switch self {
    case .listingUnavailable:
      return "Refresh is currently unavailable."
    }
  }
}

/// Owns the navigation controller and assembles feature modules.
///
/// Also the mediator for the one cross-module contract: Details' Refresh button
/// is forwarded to the Listing module (which owns data loading), so the cache
/// and both screens update from a single code path while Details stays unaware
/// of the network layer.
@MainActor
final class AppFlowCoordinator {
  private let dependencies: AppDependencies
  private let navigationController: UINavigationController
  
  /// The presenter behind it is retained by the listing screen itself.
  private weak var listingInput: ListingModuleInput?
  
  init(dependencies: AppDependencies) {
    self.dependencies = dependencies
    navigationController = UINavigationController()
    navigationController.navigationBar.prefersLargeTitles = true
  }
  
  /// Builds the root listing screen and returns the ready navigation stack.
  func start() -> UIViewController {
    let router = ListingRouter(navigationController: navigationController) { [weak self] university in
      self?.makeDetailsScreen(for: university) ?? UIViewController()
    }
    let module = ListingModuleFactory.makeModule(
      country: AppConfiguration.country,
      loadUniversitiesUseCase: dependencies.loadUniversitiesUseCase,
      refreshUniversitiesUseCase: dependencies.refreshUniversitiesUseCase,
      router: router
    )
    listingInput = module.input
    navigationController.setViewControllers([module.viewController], animated: false)
    return navigationController
  }
  
  private func makeDetailsScreen(for university: University) -> UIViewController {
    DetailsModuleFactory.makeModule(
      university: university,
      output: self,
      navigationController: navigationController
    )
  }
}

// MARK: - DetailsModuleOutput

extension AppFlowCoordinator: DetailsModuleOutput {
  func detailsDidRequestRefresh(for university: University) async throws -> University? {
    guard let listingInput else {
      throw AppFlowError.listingUnavailable
    }
    let universities = try await listingInput.refreshFromExternalTrigger()
    return universities.first { $0.id == university.id }
  }
}
