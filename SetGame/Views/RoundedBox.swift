import Foundation
import SwiftUI

private struct defaults {
    fileprivate static let background:      Color       = .clear;
    fileprivate static let radius:          CGFloat     = 7.0;
    fileprivate static let padding:         Padding     = .empty;
    fileprivate static let margins:         Margins     = .empty;
    fileprivate static let span:            Bool        = false;
    fileprivate static let wrap:            Bool        = false;
    fileprivate static let border:          Color       = .clear;
    fileprivate static let borderSize:      Int         = 1;
    fileprivate static let shadow:          Bool        = false;
    fileprivate static let shadowColor:     Color       = .black;
    fileprivate static let shadowStrength:  CGFloat     = 0.5;
    fileprivate static let title:           String?     = nil;
    fileprivate static let titleSize:       Int         = 18;
    fileprivate static let titleWeight:     Font.Weight = .bold;
    fileprivate static let disabledOpacity: CGFloat     = 0.6;
}

public struct RoundedBox<Content: View>: View {

    private let background:     Color;
    private let radius:         CGFloat;
    private let padding:        Padding;
    private let margins:        Margins;
    private let span:           Bool;
    private let wrap:           Bool;
    private let border:         Color;
    private let borderSize:     Int;
    private let shadow:         Bool;
    private let shadowColor:    Color;
    private let shadowStrength: CGFloat;
    private let height:         CGFloat?;
    private let title:          String?;
    private let titleSize:      Int;
    private let titleWeight:    Font.Weight;
    private let disabled:       Bool;
    private let content:        Content;

    public init(background:     Color?       = nil,
                radius:         CGFloat?     = nil,
                padding:        Padding?     = nil,
                margins:        Margins?     = nil,
                span:           Bool?        = nil,
                wrap:           Bool?        = nil,
                border:         Color?       = nil,
                borderSize:     Int?         = nil,
                shadow:         Bool?        = nil,
                shadowColor:    Color?       = nil,
                shadowStrength: CGFloat?     = nil,
                height:         CGFloat?     = nil,
                title:          String?      = nil,
                titleSize:      Int?         = nil,
                titleWeight:    Font.Weight? = nil,
                disabled:       Bool         = false,
                @ViewBuilder content: () -> Content) {

        self.background     = background     ?? defaults.background;
        self.radius         = radius         ?? defaults.radius;
        self.padding        = padding        ?? defaults.padding;
        self.margins        = margins        ?? defaults.margins;
        self.span           = span           ?? defaults.span;
        self.wrap           = wrap           ?? defaults.wrap;
        self.border         = border         ?? defaults.border;
        self.borderSize     = borderSize     ?? defaults.borderSize;
        self.shadow         = shadow         ?? defaults.shadow;
        self.shadowColor    = shadowColor    ?? defaults.shadowColor;
        self.shadowStrength = shadowStrength ?? defaults.shadowStrength;
        self.height         = height;
        self.title          = title          ?? defaults.title;
        self.titleSize      = titleSize      ?? defaults.titleSize;
        self.titleWeight    = titleWeight    ?? defaults.titleWeight;
        self.disabled       = disabled;
        self.content        = content();
    }

    public var body: some View {
        if let title: String = self.title {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: CGFloat(self.titleSize), weight: self.titleWeight))
                    .padding(.leading, self.margins.leading + 1)
                    .padding(.top, self.margins.top)
                    .padding(.bottom, 1)
                RoundedBox(background:     self.background,
                           radius:         self.radius,
                           padding:        self.padding,
                           margins:        Margins(self.margins, top: 0),
                           span:           true,
                           border:         self.border,
                           borderSize:     self.borderSize,
                           shadow:         self.shadow,
                           shadowColor:    self.shadowColor,
                           shadowStrength: self.shadowStrength,
                           title:          nil) {
                    self.content
                }
            }
        }
        else {
            HStack(spacing: 0) {
                self.content ; if (self.span) { Spacer() }
            }
            .frame(height: self.height)
            .rounded(background:     self.background,
                     radius:         self.radius,
                     padding:        self.padding,
                     margins:        self.margins,
                     wrap:           self.wrap,
                     border:         self.border,
                     borderSize:     self.borderSize,
                     shadow:         self.shadow,
                     shadowColor:    self.shadowColor,
                     shadowStrength: self.shadowStrength,
                     disabled:       self.disabled)
        }
    }
}

public extension View {

    public func rounded(background:     Color?   = nil,
                        radius:         CGFloat? = nil,
                        padding:        Padding? = nil,
                        margins:        Margins? = nil,
                        wrap:           Bool?    = nil,
                        border:         Color?   = nil,
                        borderSize:     Int?     = nil,
                        shadow:         Bool?    = nil,
                        shadowColor:    Color?   = nil,
                        shadowStrength: CGFloat? = nil,
                        disabled:       Bool     = false) -> some View {

        let background:     Color   = background     ?? defaults.background;
        let radius:         CGFloat = radius         ?? defaults.radius;
        let padding:        Padding = padding        ?? defaults.padding;
        let margins:        Margins = margins        ?? defaults.margins;
        let wrap:           Bool    = wrap           ?? defaults.wrap;
        let border:         Color   = border         ?? defaults.border;
        let borderSize:     Int     = borderSize     ?? defaults.borderSize;
        let shadow:         Bool    = shadow         ?? defaults.shadow;
        let shadowColor:    Color   = shadowColor    ?? defaults.shadowColor;
        let shadowStrength: CGFloat = shadowStrength ?? defaults.shadowStrength;

        return self.padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .circular)
                    //
                    // N.B. The shadow does not (2026-03-16)
                    // work when the background is Color.clear.
                    //
                    .fill(disabled ? background.opacity(defaults.disabledOpacity) : background)
                    .shadow(color:  shadow ? shadowColor.opacity(shadowStrength) : .clear,
                            radius: shadow ? 8 : 0,
                            x:      shadow ? 3 : 0,
                            y:      shadow ? 6 : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .circular)
                    .stroke(border, lineWidth: CGFloat(borderSize))
            )
            .margins(margins)
            .lineLimit(wrap ? nil : 1)
    }
}
