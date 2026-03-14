import Foundation
import SwiftUI

public struct RoundedBox<Content: View>: View {

    private let background: Color;
    private let padding: Padding?;
    private let margin: Margin?;
    private let radius: CGFloat;
    private let shadow: Bool;
    private let border: Color?;
    private let borderThickness: Int?;
    private let content: Content;

    public init(background: Color,
                padding: Padding? = nil,
                margin: Margin? = nil,
                radius: CGFloat = 5.0,
                shadow: Bool = false,
                border: Color? = nil,
                borderThickness: Int? = nil,
                @ViewBuilder content: () -> Content) {
        self.background = background;
        self.padding = padding;
        self.margin = margin;
        self.radius = radius;
        self.shadow = shadow;
        self.border = border;
        self.borderThickness = borderThickness;
        self.content = content();
    }

    public var body: some View {
        HStack(spacing: 0) {
            self.content
        }
        .rounded(background: self.background,
                 padding: self.padding, margin: self.margin,
                 radius: self.radius, shadow: self.shadow,
                 border: self.border, borderThickness: self.borderThickness)
    }
}

public extension View {

    public func rounded(background: Color,
                        padding: Padding? = nil,
                        margin: Margin? = nil,
                        radius: CGFloat = 5.0,
                        shadow: Bool = true,
                        wrap: Bool = false,
                        border: Color? = nil,
                        borderThickness: Int? = nil,
                        disabled: Bool = false) -> some View {
        self.padding(padding ?? Padding.fallback)
            .background(RoundedRectangle(cornerRadius: radius, style: .circular)
                        .fill(disabled ? background.opacity(0.65) : background))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .circular)
                     .stroke(border ?? .clear, lineWidth: CGFloat(borderThickness ?? 0)))
            .margin(margin ?? Margin.fallback)
            .shadow(color: shadow ? .black.opacity(0.3) : .clear,
                    radius: shadow ? 8 : 0, x: shadow ? 3 : 0, y: shadow ? 6 : 0)
            .lineLimit(wrap ? nil : 1)
    }
}
