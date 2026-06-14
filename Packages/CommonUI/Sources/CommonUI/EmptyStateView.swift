import SwiftUI

/// Shared empty state for screens whose data source returned nothing.
public struct EmptyStateView: View {
  private let title: String
  private let message: String
  private let systemImage: String
  
  public init(
    title: String,
    message: String,
    systemImage: String = "tray"
  ) {
    self.title = title
    self.message = message
    self.systemImage = systemImage
  }
  
  public var body: some View {
    VStack(spacing: 12) {
      Image(systemName: systemImage)
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
    }
    .padding(32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#if DEBUG
struct EmptyStateView_Previews: PreviewProvider {
  static var previews: some View {
    EmptyStateView(
      title: "No Universities",
      message: "There is nothing to show for this country yet.",
      systemImage: "graduationcap"
    )
  }
}
#endif
