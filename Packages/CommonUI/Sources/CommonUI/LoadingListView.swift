import SwiftUI

/// Shared loading state: a column of shimmering row placeholders.
public struct LoadingListView: View {
  private let rowCount: Int
  
  public init(rowCount: Int = 8) {
    self.rowCount = rowCount
  }
  
  public var body: some View {
    VStack(spacing: 20) {
      ForEach(0..<rowCount, id: \.self) { _ in
        placeholderRow
      }
      Spacer(minLength: 0)
    }
    .padding(20)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Loading")
  }
  
  private var placeholderRow: some View {
    VStack(alignment: .leading, spacing: 8) {
      RoundedRectangle(cornerRadius: 6)
        .fill(Color(.systemGray5))
        .frame(height: 16)
        .frame(maxWidth: .infinity)
      RoundedRectangle(cornerRadius: 6)
        .fill(Color(.systemGray5))
        .frame(width: 140, height: 12)
    }
    .shimmering()
  }
}

#if DEBUG
struct LoadingListView_Previews: PreviewProvider {
  static var previews: some View {
    LoadingListView()
  }
}
#endif
