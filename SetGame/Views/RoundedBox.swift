import Foundation
import SwiftUI

public struct RoundedBox<Content: View>: View {

    private let background: Color;
    private let padding: Padding?;
    private let margin: Margin?;
    private let radius: CGFloat;
    private let shadow: Bool;
    private let content: Content;

    public init(background: Color,
                padding: Padding? = nil,
                margin: Margin? = nil,
                radius: CGFloat = 5.0,
                shadow: Bool = false,
                @ViewBuilder content: () -> Content) {
        self.background = background;
        self.padding = padding;
        self.margin = margin;
        self.radius = radius;
        self.shadow = shadow;
        self.content = content();
    }

    public var body: some View {
        HStack(spacing: 0) {
            self.content
        }
        .rounded(background: self.background,
                 padding: self.padding, margin: self.margin,
                 radius: self.radius, shadow: self.shadow)
    }
}

public extension View {

    public func rounded(background: Color, padding: Padding? = nil, margin: Margin? = nil,
                        radius: CGFloat = 5.0, shadow: Bool = false,
                        disabled: Bool = false, wrap: Bool = false) -> some View {
        self.padding(padding ?? Padding.fallback)
            .background(RoundedRectangle(cornerRadius: radius, style: .circular)
                        .fill(disabled ? background.opacity(0.65) : background))
            .margin(margin ?? Margin.fallback)
            .shadow(color: shadow ? .black.opacity(0.3) : .clear,
                    radius: shadow ? 8 : 0, x: shadow ? 3 : 0, y: shadow ? 6 : 0)
            .lineLimit(wrap ? nil : 1)
    }
}
