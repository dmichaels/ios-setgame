import Foundation
import SwiftUI

public struct TextBox: View {

    private let text:       String?;
    private let icon:       String?;
    private let foreground: Color;
    private let background: Color;
    private let size:       Int;
    private let weight:     Font.Weight;
    private let padding:    Padding;
    private let margins:    Margins;
    private let border:     Color;
    private let borderSize: Int;
    private let shadow:     Bool;
    private let disabled:   Bool;

    public init(_ text:       String?      = nil,
                  icon:       String?      = nil,
                  foreground: Color?       = nil,
                  background: Color?       = nil,
                  size:       Int?         = nil,
                  weight:     Font.Weight? = nil,
                  padding:    Padding?     = nil,
                  margins:    Margins?     = nil,
                  border:     Color?       = nil,
                  borderSize: Int?         = nil,
                  shadow:     Bool?        = nil,
                  disabled:   Bool         = false) {

        self.text       = text;
        self.icon       = icon;
        self.foreground = foreground ?? .white;
        self.background = background ?? .blue;
        self.size       = size       ?? 18;
        self.weight     = weight     ?? .semibold;
        self.padding    = padding    ?? Padding(horizontal: 8, vertical: 8);
        self.margins    = margins    ?? Margins.empty;
        self.border     = border     ?? .clear;
        self.borderSize = borderSize ?? 1;
        self.shadow     = shadow     ?? false;
        self.disabled   = disabled;
    }

    private static func iconSize(_ size: Int, _ weight: Font.Weight) -> CGFloat {
        switch weight {
            case .ultraLight, .thin: return CGFloat(size) * 1.00;
            case .light:             return CGFloat(size) * 0.97;
            case .regular:           return CGFloat(size) * 0.92;
            case .medium:            return CGFloat(size) * 0.90;
            case .semibold:          return CGFloat(size) * 0.87;
            case .bold, .heavy:      return CGFloat(size) * 0.84;
            default:                 return CGFloat(size) * 0.94;
        }
    }

    private static func boxHeight(_ size: Int) -> CGFloat {
        return CGFloat(size) * 1.20;
    }

    public var body: some View {
        RoundedBox(background: self.background,
                   padding: self.padding, margins: self.margins,
                   border: self.border, borderSize: self.borderSize,
                   shadow: self.shadow,
                   height: TextBox.boxHeight(self.size),
                   disabled: self.disabled) {
            if let icon: String = self.icon {
                Image(systemName: icon)
                    .foregroundColor(self.disabled ? self.foreground.opacity(0.65) : self.foreground)
                    .font(.system(size: TextBox.iconSize(self.size, self.weight), weight: self.weight))
                    .disabled(self.disabled)
            }
            if let text: String = self.text {
                Text(text)
                    .font(.system(size: CGFloat(self.size), weight: self.weight))
                    .foregroundColor(self.disabled ? self.foreground.opacity(0.6) : self.foreground)
                    .padding(.leading, icon != nil ? 8 : 0)
                    .padding(.trailing, icon != nil ? 2 : nil)
            }
        }
    }
}

public struct ButtonBox: View {

    private let text:       String?;
    private let icon:       String?;
    private let foreground: Color?;
    private let background: Color?;
    private let size:       Int?;
    private let weight:     Font.Weight?;
    private let padding:    Padding?;
    private let margins:    Margins?;
    private let border:     Color?;
    private let borderSize: Int?;
    private let shadow:     Bool?;
    private let disabled:   Bool;
    private let action:     () async -> Void;

    public init( _ text:       String?      = nil,
                   icon:       String?      = nil,
                   foreground: Color?       = nil,
                   background: Color?       = nil,
                   size:       Int?         = nil,
                   weight:     Font.Weight? = nil,
                   padding:    Padding?     = nil,
                   margins:    Margins?     = nil,
                   border:     Color?       = nil,
                   borderSize: Int?         = nil,
                   shadow:     Bool?        = nil,
                   disabled:   Bool         = false,
                   action: @escaping () async -> Void) {

        self.text       = text;
        self.icon       = icon;
        self.foreground = foreground;
        self.background = background;
        self.size       = size;
        self.weight     = weight;
        self.padding    = padding;
        self.margins    = margins;
        self.border     = border;
        self.borderSize = borderSize;
        self.shadow     = shadow;
        self.disabled   = disabled;
        self.action     = action;
    }

    public var body: some View {
        Button {
            if (!self.disabled) { Task {
                await self.action();
            } }
        } label: {
            TextBox(text,
                    icon:       self.icon,
                    foreground: self.foreground,
                    background: self.background,
                    size:       self.size,
                    weight:     self.weight,
                    padding:    self.padding,
                    margins:    self.margins,
                    border:     self.border,
                    borderSize: self.borderSize,
                    shadow:     self.shadow,
                    disabled:   self.disabled)
        }
        .buttonStyle(.plain)
    }
}

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
    fileprivate static let height:          CGFloat?    = nil;
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
        self.height         = height         ?? defaults.height;
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
