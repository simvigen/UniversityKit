import SwiftUI

/// Animated highlight sweep used by loading placeholders.
private struct ShimmerModifier: ViewModifier {
  @State private var isAnimating = false
  
  func body(content: Content) -> some View {
    content
      .overlay(
        GeometryReader { proxy in
          LinearGradient(
            colors: [.clear, Color.white.opacity(0.55), .clear],
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(width: proxy.size.width * 0.8)
          .offset(x: isAnimating ? proxy.size.width * 1.4 : -proxy.size.width * 1.4)
          .animation(
            .linear(duration: 1.2).repeatForever(autoreverses: false),
            value: isAnimating
          )
        }
      )
      .mask(content)
      .onAppear { isAnimating = true }
  }
}

public extension View {
  /// Applies a repeating shimmer sweep, typically over placeholder shapes.
  func shimmering() -> some View {
    modifier(ShimmerModifier())
  }
}
