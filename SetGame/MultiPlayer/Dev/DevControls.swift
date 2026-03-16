import SwiftUI

public extension MultiPlayer.Dev {

    public struct TextBox: View {

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

    public struct TextButton: View {

        private let text:       String;
        private let foreground: Color;
        private let background: Color;
        private let size:       Int;
        private let padding:    Padding;
        private let margins:    Margins;
        private let weight:     Font.Weight;
        private let disabled:   Bool;
        private let action:     () async -> Void;

        public init( _ text:       String,
                       size:       Int?         = nil,
                       padding:    Padding?     = nil,
                       margins:    Margins?     = nil,
                       weight:     Font.Weight? = nil,
                       foreground: Color?       = nil,
                       background: Color?       = nil,
                       disabled:   Bool         = false,
                       action: @escaping () async -> Void) {

            self.text       = text;
            self.size       = size       ?? Defaults.fontSize;
            self.padding    = padding    ?? Defaults.padding;
            self.margins    = margins    ?? Margins.empty;
            self.weight     = weight     ?? Font.Weight.semibold;
            self.foreground = foreground ?? Color.white;
            self.background = background ?? Defaults.foreground;
            self.disabled   = disabled;
            self.action     = action;
        }

        public var body: some View {
            Button {
                if (!self.disabled) { Task {
                    await self.action();
                } }
            } label: {
                RoundedBox(background: self.background, padding: self.padding,
                                                        margins: self.margins, disabled: self.disabled) {
                    TextBox(self.text, color: self.foreground, weight: .semibold, disabled: self.disabled)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
