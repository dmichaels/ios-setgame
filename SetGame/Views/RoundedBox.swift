import Foundation
import SwiftUI

public struct RoundedBox<Content: View>: View {

    private let background: Color;
    private let padding: Padding?;
    private let margin: Margin?;
    private let shadow: Bool;
    private let content: Content;

    public init(background: Color, padding: Padding? = nil, margin: Margin? = nil,
                shadow: Bool = false, @ViewBuilder content: () -> Content) {
        self.background = background;
        self.padding = padding;
        self.margin = margin;
        self.shadow = shadow;
        self.content = content();
    }

    public init(background: Color, spacing: Spacing? = nil, shadow: Bool = false, @ViewBuilder content: () -> Content) {
        self.init(background: background,
                  padding: spacing?.padding, margin: spacing?.margin,
                  shadow: shadow, content: content);
    }

    public var body: some View {
        HStack(spacing: 0) {
            self.content
        }
        .rounded(background: self.background, padding: self.padding, margin: self.margin, shadow: shadow)
    }
}

public extension View {

    public func rounded(background: Color, padding: Padding? = nil, margin: Margin? = nil,
                        disabled: Bool = false, radius: CGFloat = 5.0,
                        shadow: Bool = false, wrap: Bool = false) -> some View {
        self.padding(padding ?? Padding.fallback)
            .background(RoundedRectangle(cornerRadius: radius, style: .circular)
                        .fill(disabled ? background.opacity(0.65) : background))
            .margin(margin ?? Margin.fallback)
            .shadow(color: shadow ? .black.opacity(0.3) : .clear,
                    radius: shadow ? 8 : 0, x: shadow ? 3 : 0, y: shadow ? 6 : 0)
            .lineLimit(wrap ? nil : 1)
    }

    public func rounded(background: Color, spacing: Spacing? = nil,
                        disabled: Bool = false, radius: CGFloat = 5.0,
                        shadow: Bool = false, wrap: Bool = false) -> some View {
        self.padding(spacing ?? Spacing.fallback)
            .background(RoundedRectangle(cornerRadius: radius, style: .circular)
                        .fill(disabled ? background.opacity(0.65) : background))
            .margin(spacing ?? Spacing.fallback)
            .shadow(color: shadow ? .black.opacity(0.3) : .clear,
                    radius: shadow ? 8 : 0, x: shadow ? 3 : 0, y: shadow ? 6 : 0)
            .lineLimit(wrap ? nil : 1)
    }
}
