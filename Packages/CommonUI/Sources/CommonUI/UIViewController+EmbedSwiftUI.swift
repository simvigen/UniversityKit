import SwiftUI
import UIKit

@MainActor
public extension UIViewController {
  /// Embeds a SwiftUI view as a full-bleed child `UIHostingController`.
  /// Shared by every feature so the UIKit↔SwiftUI bridge lives in one place.
  @discardableResult
  func embedSwiftUIView<Content: View>(_ content: Content) -> UIHostingController<Content> {
    let hosting = UIHostingController(rootView: content)
    hosting.view.backgroundColor = .clear
    
    addChild(hosting)
    hosting.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(hosting.view)
    NSLayoutConstraint.activate([
      hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
      hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    hosting.didMove(toParent: self)
    return hosting
  }
}
