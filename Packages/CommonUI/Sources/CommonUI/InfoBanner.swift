import SwiftUI

/// Compact inline banner for non-blocking notices (cached data, refresh failures).
public struct InfoBanner: View {
  public enum Style {
    case info
    case warning
  }
  
  private let message: String
  private let style: Style
  
  public init(message: String, style: Style = .info) {
    self.message = message
    self.style = style
  }
  
  public var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 8) {
      Image(systemName: iconName)
      Text(message)
        .fixedSize(horizontal: false, vertical: true)
      Spacer(minLength: 0)
    }
    .font(.footnote)
    .foregroundColor(foregroundColor)
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(backgroundColor)
    .cornerRadius(10)
  }
  
  private var iconName: String {
    switch style {
    case .info: return "info.circle"
    case .warning: return "exclamationmark.triangle"
    }
  }
  
  private var foregroundColor: Color {
    switch style {
    case .info: return .blue
    case .warning: return .orange
    }
  }
  
  private var backgroundColor: Color {
    switch style {
    case .info: return Color.blue.opacity(0.12)
    case .warning: return Color.orange.opacity(0.14)
    }
  }
}

#if DEBUG
struct InfoBanner_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 12) {
      InfoBanner(message: "Showing cached results — pull to refresh.", style: .warning)
      InfoBanner(message: "Everything is up to date.")
    }
    .padding()
  }
}
#endif
