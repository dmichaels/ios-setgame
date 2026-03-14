import Foundation
import SwiftUI

public struct RoundedBox<Content: View>: View {

    private let background: Color;
    private let padding: Padding?;
    private let margins: Margins?;
    private let radius: CGFloat;
    private let span: Bool;
    private let shadow: Bool;
    private let border: Color?;
    private let borderThickness: Int?;
    private let content: Content;

    public init(background: Color,
                padding: Padding? = nil,
                margins: Margins? = nil,
                radius: CGFloat = 5.0,
                span: Bool = false,
                shadow: Bool = false,
                border: Color? = nil,
                borderThickness: Int? = nil,
                @ViewBuilder content: () -> Content) {
        self.background = background;
        self.padding = padding;
        self.margins = margins;
        self.radius = radius;
        self.span = span;
        self.shadow = shadow;
        self.border = border;
        self.borderThickness = borderThickness;
        self.content = content();
    }

    public var body: some View {
        HStack(spacing: 0) {
            self.content
            if (self.span) { Spacer() }
        }
        .rounded(background: self.background,
                 padding: self.padding, margins: self.margins,
                 radius: self.radius, shadow: self.shadow,
                 border: self.border, borderThickness: self.borderThickness)
    }
}

public extension View {

    public func rounded(background: Color,
                        padding: Padding? = nil,
                        margins: Margins? = nil,
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
            .margins(margins ?? Margins.fallback)
            .shadow(color: shadow ? .black.opacity(0.3) : .clear,
                    radius: shadow ? 8 : 0, x: shadow ? 3 : 0, y: shadow ? 6 : 0)
            .lineLimit(wrap ? nil : 1)
    }
}
