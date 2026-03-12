import Foundation
import SwiftUI

public struct RoundedBox<Content: View>: View {
    private let background: Color;
    private let spacing: Spacing?;
    private let shadow: Bool;
    private let content: Content;
    public init(background: Color, spacing: Spacing? = nil, shadow: Bool = false, @ViewBuilder content: () -> Content) {
        self.background = background;
        self.spacing = spacing;
        self.shadow = shadow;
        self.content = content();
    }
    public var body: some View {
        HStack(spacing: 0) { self.content }
            .rounded(background: self.background, spacing: self.spacing, shadow: shadow)
    }
}

public extension View {
    public func rounded(background: Color, spacing: Spacing? = nil,
                        disabled: Bool = false, radius: CGFloat = 5.0,
                        shadow: Bool = false, wrap: Bool = false) -> some View {
        self.padding(spacing ?? Spacing.defaults)
            .background(RoundedRectangle(cornerRadius: radius, style: .circular)
                        .fill(disabled ? background.opacity(0.75) : background))
            .margin(spacing ?? Spacing.defaults)
            .shadow(color: shadow ? .black.opacity(0.3) : .clear,
                    radius: shadow ? 8 : 0, x: shadow ? 3 : 0, y: shadow ? 6 : 0)
            .lineLimit(wrap ? nil : 1)
    }
}
