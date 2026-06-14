import SwiftUI

/// Shared full-screen error state with a retry action.
public struct ErrorStateView: View {
  private let title: String
  private let message: String
  private let retryTitle: String
  private let onRetry: () -> Void
  
  public init(
    title: String = "Something Went Wrong",
    message: String,
    retryTitle: String = "Try Again",
    onRetry: @escaping () -> Void
  ) {
    self.title = title
    self.message = message
    self.retryTitle = retryTitle
    self.onRetry = onRetry
  }
  
  public var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "wifi.exclamationmark")
        .font(.system(size: 44, weight: .regular))
        .foregroundColor(.secondary)
      
      Text(title)
        .font(.title3.weight(.semibold))
        .multilineTextAlignment(.center)
      
      Text(message)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
      
      Button(action: onRetry) {
        Text(retryTitle)
          .font(.headline)
          .padding(.horizontal, 24)
          .padding(.vertical, 6)
      }
      .buttonStyle(.borderedProminent)
      .padding(.top, 8)
    }
    .padding(32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#if DEBUG
struct ErrorStateView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorStateView(message: "You appear to be offline. Check your connection and try again.") {}
  }
}
#endif
