import Combine
import CommonUI
import SwiftUI
import UIKit

/// VIPER View: UIKit container with a UIKit Refresh bar button.
/// The button swaps to a spinner while a refresh is in flight, driven by a
/// Combine subscription to the presenter's state stream.
final class DetailsViewController: UIViewController {
  private let presenter: DetailsPresenter
  private var cancellables = Set<AnyCancellable>()
  
  private lazy var refreshButton = UIBarButtonItem(
    title: "Refresh",
    style: .plain,
    target: self,
    action: #selector(refreshTapped)
  )
  
  private lazy var spinnerItem: UIBarButtonItem = {
    let spinner = UIActivityIndicatorView(style: .medium)
    spinner.startAnimating()
    return UIBarButtonItem(customView: spinner)
  }()
  
  init(presenter: DetailsPresenter) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Details"
    view.backgroundColor = .systemGroupedBackground
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.rightBarButtonItem = refreshButton
    embedSwiftUIView(DetailsView(presenter: presenter))
    bindState()
  }
  
  private func bindState() {
    presenter.$state
      .map(\.isRefreshing)
      .removeDuplicates()
      .sink { [weak self] isRefreshing in
        guard let self else { return }
        self.navigationItem.rightBarButtonItem = isRefreshing
        ? self.spinnerItem
        : self.refreshButton
      }
      .store(in: &cancellables)
  }
  
  @objc
  private func refreshTapped() {
    presenter.send(.refreshTapped)
  }
}
