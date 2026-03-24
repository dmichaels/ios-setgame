import SwiftUI

public extension MultiPlayer.Dev {

    public struct DevPanelView<Content: View>: View {

        private let padding: Padding;
        private let margins: Margins;
        private let title:   String?;
        private let content: Content;

        private let background: Color   = Defaults.background;
        private let radius:     CGFloat = 8;
        private let border:     Color?  = Defaults.foreground;
        private let borderSize: Int     = 2;
        private let shadow:     Bool    = false;

        public init(table: Table, padding: Padding? = nil, margins: Margins? = nil,
                    title: String? = nil, @ViewBuilder content: () -> Content) {
            self.padding = Padding(padding, horizontal: 8, vertical: 8);
            self.margins = Margins(margins, horizontal: 10);
            self.title   = title;
            self.content = content();
        }

        public var body: some View {
            RoundedBox(radius:     self.radius,
                       padding:    self.padding,
                       margins:    self.margins,
                       span:       true,
                       border:     self.border,
                       borderSize: self.borderSize,
                       background: self.background,
                       shadow:     self.shadow,
                       title:      self.title) {
                self.content
            }
        }
    }

    public struct JoinControl: View {

        @Binding fileprivate var items: PrefixableList;
        private let size: Int;
        private let padding: Padding;
        private let margins: Margins;
        private let foreground: Color;
        private let background: Color;
        private let weight: Font.Weight;
        private let disabled: Bool;
        private let action: () async -> Void;

        private static let padding: Padding = Padding(leading: 8, trailing: 8, top: 4, bottom: 4);

        public init(items: Binding<PrefixableList>,
                    size: Int? = nil, padding: Padding? = nil, margins: Margins? = nil,
                    foreground: Color? = nil, background: Color? = nil,
                    weight: Font.Weight = .semibold,
                    disabled: Bool = false, action: @escaping () async -> Void) {
            self._items = items;
            self.size = size ?? Defaults.fontSize;
            self.padding = padding ?? Defaults.padding;
            self.margins = margins ?? Margins.empty;
            self.foreground = foreground ?? Defaults.foregroundButton;
            self.background = background ?? Defaults.backgroundButton;
            self.weight = weight;
            self.disabled = disabled;
            self.action = action;
        }

        public var body: some View {
            RoundedBox(padding: Padding(6), /*padding: self.padding,*/ margins: self.margins, border: .black, background: self.background) {
                Button {
                    if (!self.disabled) { Task {
                        await self.action();
                    } }
                } label: {
                    TextBox("join: ", padding: Padding.empty, foreground: self.foreground, background: self.background)
                    /*
                    Text("join: ")
                        // .font(.system(size: CGFloat(self.size), weight: self.weight))
                        .foregroundColor(self.disabled ? self.foreground.opacity(0.65) : self.foreground)
                        */
                }.buttonStyle(.plain)
                Menu {
                    ForEach(self.items.prefixes, id: \.self) { item in
                        Button(item) { self.items.select(item) }
                    }
                }
                label: {
                    TextBox(self.items.selected(prefix: true) ?? Defaults.emptySetChar, padding: Padding.empty, foreground: self.foreground, background: self.background)
                    /*
                    Text(self.items.selected(prefix: true) ?? Defaults.emptySetChar)
                        .font(.system(size: CGFloat(self.size), weight: self.weight))
                        .foregroundColor(self.disabled ? self.foreground.opacity(0.65) : self.foreground)
                        */
                }
                .disabled(self.disabled)
            }
        }
    }

    public struct IconButton: View {
        private let icon: String;
        private let color: Color;
        private let size: Int;
        private var bold: Bool;
        private let disabled: Bool;
        private let action: () async -> Void;
        public init(_ icon: String,
                    color: Color? = nil,
                    size: Int? = nil,
                    bold: Bool = false,
                    disabled: Bool = false,
                    action: @escaping () async -> Void) {
            self.icon = icon;
            self.color = color ?? Defaults.foreground;
            self.size = size ?? Defaults.iconSize;
            self.bold = bold;
            self.disabled = disabled;
            self.action = action;
        }
        public var body: some View {
            ButtonBox(icon: self.icon,
                      padding: Padding.empty,
                      // size: self.size,
                      // weight: self.bold ? .bold : .regular,
                      foreground: self.color,
                      background: Defaults.background,
                      disabled: self.disabled,
                      action: self.action
            )
        }
    }

    public struct RegularText: View {
        private let text: String;
        private let size: Int;
        private var bold: Bool = false;
        private var semibold: Bool = false;
        private var strikeout: Bool = false;
        private let leading: Int;
        private let trailing: Int;
        private let color: Color;
        public init(_ text: String,
                      size: Int = Defaults.fontSize,
                      bold: Bool = false, semibold: Bool = false, strikeout: Bool = false,
                      leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil,
                      color: Color = .primary) {
            self.text = text;
            self.size = size;
            self.bold = bold;
            self.semibold = semibold;
            self.strikeout = strikeout;
            self.leading = leading ?? padding ?? 0;
            self.trailing = trailing ?? padding ?? 0;
            self.color = color;
        }
        public var body: some View {
            Text(self.text)
                .font(.system(size: CGFloat(self.size), weight: bold ? .bold : (semibold ? .semibold : .regular)))
                .foregroundColor(self.color)
                .padding(.leading, CGFloat(self.leading)).padding(.trailing, CGFloat(self.trailing))
                .strikethrough(self.strikeout)
        }
    }

    public struct CopyableText: View {

        private let text: String;
        private var copy: String?;
        private let color: Color;
        private var background: Color = .white;
        private let size: Int;
        private let bold: Bool;
        private let semibold: Bool;
        private let underline: Bool;
        private var strikeout: Bool = false;
        private let leading: Int;
        private let trailing: Int;
        private let verticalPadding: Int = 4;
        @State private var copied: Bool = false;

        public init(_ text: String, copy: String? = nil, color: Color = .primary,
                      size: Int = Defaults.fontSize,
                      bold: Bool = false, semibold: Bool = false, underline: Bool = false,
                      leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil) {
            self.text = text;
            self.copy = copy ?? text;
            self.color = color;
            self.size = size;
            self.bold = bold;
            self.semibold = semibold;
            self.underline = underline;
            self.leading = leading ?? padding ?? 0;
            self.trailing = trailing ?? padding ?? 0;
        }

        public var body: some View {
            Text(text)
                .font(.system(size: CGFloat(self.size), weight: bold ? .bold : (semibold ? .semibold : .regular)))
                .underline(underline)
                .strikethrough(strikeout)
                .padding(.vertical, CGFloat(self.verticalPadding))
                .cornerRadius(8)
                .foregroundColor(self.color)
                .padding(.leading, CGFloat(self.leading)).padding(.trailing, CGFloat(self.trailing))
                .onTapGesture {
                    UIPasteboard.general.string = copy ?? text;
                    copied = true;
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                }
                .overlay(
                    copied ? Text(" Copied ")
                        .font(.caption)
                        .foregroundColor(.black)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(6)
                        .offset(y: -36)
                        .transition(.opacity)
                        .fixedSize()
                    : nil
                )
        }
    }

    public struct PollSpinner: View {
        private let count: Int;
        private let size: Int;
        private let color: Color;
        private let steps: Int = 12;
        public init(count: Int, size: Int? = nil, color: Color? = nil) {
            self.count = count;
            self.size = size ?? Defaults.iconSize;
            self.color = color ?? Defaults.iconColor;
        }
        public var body: some View {
            let angle = Double(count % steps) * (360.0 / Double(steps))
            TextBox(icon: "arrow.triangle.2.circlepath", weight: .bold, padding: Padding.empty, foreground: .black, background: Defaults.background)
                .rotationEffect(.degrees(angle))
                .animation(nil, value: self.count)
                .offset(y: 0.2)
            /*
            Image(systemName: "arrow.triangle.2.circlepath")
                .rotationEffect(.degrees(angle))
                .font(.system(size: CGFloat(self.size - 1), weight: .semibold))
                .foregroundColor(color)
                .animation(nil, value: self.count)
                .offset(y: 0.2)
                */
        }
    }
    public struct old_PollSpinner: View {
        private let count: Int;
        private let size: Int;
        private let color: Color;
        private let steps: Int = 12;
        public init(count: Int, size: Int? = nil, color: Color? = nil) {
            self.count = count;
            self.size = size ?? Defaults.iconSize;
            self.color = color ?? Defaults.iconColor;
        }
        public var body: some View {
            let angle = Double(count % steps) * (360.0 / Double(steps))
            Image(systemName: "arrow.triangle.2.circlepath")
                .rotationEffect(.degrees(angle))
                .font(.system(size: CGFloat(self.size - 1), weight: .semibold))
                .foregroundColor(color)
                .animation(nil, value: self.count)
                .offset(y: 0.2)
        }
    }
}
