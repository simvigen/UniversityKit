import CommonUI
import SwiftUI
import UIKit

/// VIPER View: UIKit container hosting the SwiftUI listing screen.
final class ListingViewController: UIViewController {
  private let presenter: ListingPresenter
  
  init(presenter: ListingPresenter) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Universities"
    view.backgroundColor = .systemGroupedBackground
    navigationItem.largeTitleDisplayMode = .always
    embedSwiftUIView(ListingView(presenter: presenter))
  }
}
