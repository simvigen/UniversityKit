import DomainKit
import Foundation

/// Everything the view can ask of the module (MVI intents).
public enum DetailsIntent {
  case refreshTapped
}

/// Single source of truth for the details screen.
public struct DetailsViewState: Equatable {
  public var university: University
  public var isRefreshing: Bool
  public var notice: Notice?
  
  public struct Notice: Equatable {
    public enum Kind: Equatable {
      case info
      case warning
    }
    
    public let kind: Kind
    public let message: String
    
    public init(kind: Kind, message: String) {
      self.kind = kind
      self.message = message
    }
  }
  
  public init(university: University, isRefreshing: Bool = false, notice: Notice? = nil) {
    self.university = university
    self.isRefreshing = isRefreshing
    self.notice = notice
  }
}
