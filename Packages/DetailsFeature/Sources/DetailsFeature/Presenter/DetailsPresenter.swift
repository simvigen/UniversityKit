import Combine
import DomainKit
import Foundation

/// VIPER Presenter, exposed to SwiftUI as an ObservableObject.
/// `state` is the screen's single source of truth (MVI).
@MainActor
public final class DetailsPresenter: ObservableObject {
  @Published public private(set) var state: DetailsViewState
  
  private let interactor: DetailsInteractorProtocol
  private let router: DetailsRouting
  
  /// Kept internal so tests can await an in-flight refresh deterministically.
  var refreshTask: Task<Void, Never>?
  
  public init(
    university: University,
    interactor: DetailsInteractorProtocol,
    router: DetailsRouting
  ) {
    self.state = DetailsViewState(university: university)
    self.interactor = interactor
    self.router = router
  }
  
  deinit {
    refreshTask?.cancel()
  }
  
  public func send(_ intent: DetailsIntent) {
    switch intent {
    case .refreshTapped:
      refresh()
    }
  }
  
  // MARK: - Private
  
  private func refresh() {
    guard !state.isRefreshing else { return }
    state.isRefreshing = true
    state.notice = nil
    refreshTask = Task { [weak self] in
      await self?.performRefresh()
    }
  }
  
  private func performRefresh() async {
    defer { state.isRefreshing = false }
    do {
      if let updated = try await interactor.refresh(current: state.university) {
        state.university = updated
        state.notice = .init(kind: .info, message: "Up to date.")
      } else {
        state.notice = .init(
          kind: .warning,
          message: "This university is no longer part of the latest results."
        )
      }
    } catch {
      state.notice = .init(kind: .warning, message: Self.message(for: error))
    }
  }
  
  private static func message(for error: Error) -> String {
    (error as? LocalizedError)?.errorDescription
    ?? "Couldn't refresh. Please try again."
  }
}
