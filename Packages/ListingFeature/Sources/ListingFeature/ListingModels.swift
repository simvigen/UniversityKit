import DomainKit
import Foundation

/// Everything the view can ask of the module (MVI intents).
public enum ListingIntent {
  case viewAppeared
  case retryTapped
  case universitySelected(University)
}

/// Single source of truth for the listing screen.
public enum ListingViewState: Equatable {
  case idle
  case loading
  case loaded(Loaded)
  case empty
  case failed(message: String)
  
  public struct Loaded: Equatable {
    public var universities: [University]
    public var origin: DataOrigin
    /// Set when a refresh failed while older data stays on screen.
    public var refreshErrorMessage: String?
    
    public init(
      universities: [University],
      origin: DataOrigin,
      refreshErrorMessage: String? = nil
    ) {
      self.universities = universities
      self.origin = origin
      self.refreshErrorMessage = refreshErrorMessage
    }
  }
}
