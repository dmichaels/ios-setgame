import SwiftUI

public extension MultiPlayer.Dev {

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
            self.foreground = foreground ?? Color.white;
            self.background = background ?? Defaults.foreground;
            self.size       = size       ?? 38; // Defaults.fontSize;
            self.weight     = weight     ?? .thin;
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
                case .light:             return CGFloat(size) * 0.95;
                case .regular:           return CGFloat(size) * 0.90;
                case .medium:            return CGFloat(size) * 0.88;
                case .semibold:          return CGFloat(size) * 0.85;
                case .bold, .heavy:      return CGFloat(size) * 0.82;
                default:                 return CGFloat(size) * 0.92;
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
                        .padding(.leading, icon != nil ? 9 : 0)
                }
            }
        }
    }

    public struct TextButton: View {

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

    public struct OLD_TextBox: View {

        private let text:     String;
        private let color:    Color;
        private let size:     Int;
        private let weight:   Font.Weight;
        private let padding:  Padding;
        private let disabled: Bool;

        public init(_ text:     String,
                      color:    Color?       = nil,
                      size:     Int?         = nil,
                      weight:   Font.Weight? = nil,
                      padding:  Padding?     = nil,
                      disabled: Bool         = false) {

            self.text     = text;
            self.color    = color    ?? .black;
            self.size     = size     ?? 17;
            self.weight   = weight   ?? .regular;
            self.padding  = padding  ?? .empty;
            self.disabled = disabled ?? false;
        }

        public var body: some View {
            Text(self.text)
                .font(.system(size: CGFloat(self.size), weight: self.weight))
                .foregroundColor(self.disabled ? self.color.opacity(0.6) : self.color)
                .padding(self.padding)
        }
    }

    public struct OLD_TextButton: View {

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
            self.foreground = foreground ?? Color.white;
            self.background = background ?? Defaults.foreground;
            self.size       = size       ?? 38; // Defaults.fontSize;
            self.weight     = weight     ?? .thin;
            self.padding    = padding    ?? Padding(horizontal: 8, vertical: 8);
            self.margins    = margins    ?? Margins.empty;
            self.border     = border     ?? .clear;
            self.borderSize = borderSize ?? 1;
            self.shadow     = shadow     ?? false;
            self.disabled   = disabled;
            self.action     = action;
        }

        private static func iconSize(_ size: Int, _ weight: Font.Weight) -> CGFloat {
            switch weight {
                case .ultraLight, .thin: return CGFloat(size) * 1.00;
                case .light:             return CGFloat(size) * 0.95;
                case .regular:           return CGFloat(size) * 0.90;
                case .medium:            return CGFloat(size) * 0.88;
                case .semibold:          return CGFloat(size) * 0.85;
                case .bold, .heavy:      return CGFloat(size) * 0.82;
                default:                 return CGFloat(size) * 0.92;
            }
        }

        private static func boxHeight(_ size: Int) -> CGFloat {
            return CGFloat(size) * 1.20;
        }

        public var body: some View {
            Button {
                if (!self.disabled) { Task {
                    await self.action();
                } }
            } label: {
                RoundedBox(background: self.background,
                           padding: self.padding, margins: self.margins,
                           border: self.border, borderSize: self.borderSize,
                           shadow: self.shadow,
                           height: OLD_TextButton.boxHeight(self.size),
                           disabled: self.disabled) {
                    if let icon: String = self.icon {
                        Image(systemName: icon)
                            .foregroundColor(self.disabled ? self.foreground.opacity(0.65) : self.foreground)
                            .font(.system(size: OLD_TextButton.iconSize(self.size, self.weight), weight: self.weight))
                            .disabled(self.disabled)
                    }
                    if let text: String = self.text {
                        Text(text)
                            .font(.system(size: CGFloat(self.size), weight: self.weight))
                            .foregroundColor(self.disabled ? self.foreground.opacity(0.6) : self.foreground)
                            .padding(.leading, icon != nil ? 9 : 0)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
