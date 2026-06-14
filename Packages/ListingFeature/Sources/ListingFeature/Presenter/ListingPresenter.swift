import Combine
import DomainKit
import Foundation

/// VIPER Presenter, exposed to SwiftUI as an ObservableObject.
/// `state` is the screen's single source of truth (MVI).
@MainActor
public final class ListingPresenter: ObservableObject {
  @Published public private(set) var state: ListingViewState = .idle
  
  private let interactor: ListingInteractorProtocol
  private let router: ListingRouting
  
  /// Kept internal so tests can await in-flight loads deterministically.
  var loadTask: Task<Void, Never>?
  
  public init(interactor: ListingInteractorProtocol, router: ListingRouting) {
    self.interactor = interactor
    self.router = router
  }
  
  deinit {
    loadTask?.cancel()
  }
  
  public func send(_ intent: ListingIntent) {
    switch intent {
    case .viewAppeared:
      // Loading is driven once by the first appearance; later
      // appearances (e.g. popping back from Details) keep state as is.
      guard case .idle = state else { return }
      load()
    case .retryTapped:
      load()
    case .universitySelected(let university):
      router.showDetails(for: university)
    }
  }
  
  /// Pull-to-refresh: keeps current content on screen if the refresh fails.
  public func refresh() async {
    do {
      try await performRefresh()
    } catch {
      if case .loaded(var loaded) = state {
        loaded.refreshErrorMessage = Self.message(for: error)
        state = .loaded(loaded)
      } else {
        state = .failed(message: Self.message(for: error))
      }
    }
  }
  
  // MARK: - Private
  
  private func load() {
    loadTask?.cancel()
    state = .loading
    loadTask = Task { [weak self] in
      await self?.performLoad()
    }
  }
  
  private func performLoad() async {
    do {
      let result = try await interactor.loadUniversities()
      guard !Task.isCancelled else { return }
      state = result.universities.isEmpty
      ? .empty
      : .loaded(.init(universities: result.universities, origin: result.origin))
    } catch is CancellationError {
      return
    } catch {
      guard !Task.isCancelled else { return }
      state = .failed(message: Self.message(for: error))
    }
  }
  
  @discardableResult
  private func performRefresh() async throws -> [University] {
    let fresh = try await interactor.refreshUniversities()
    state = fresh.isEmpty
    ? .empty
    : .loaded(.init(universities: fresh, origin: .remote))
    return fresh
  }
  
  private static func message(for error: Error) -> String {
    (error as? LocalizedError)?.errorDescription
    ?? "Something went wrong. Please try again."
  }
}

// MARK: - ListingModuleInput

extension ListingPresenter: ListingModuleInput {
  @discardableResult
  public func refreshFromExternalTrigger() async throws -> [University] {
    try await performRefresh()
  }
}
