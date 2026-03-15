import SwiftUI

public extension MultiPlayer.Dev {

    public struct AnyDevPanel<Content: View>: View {

        private let padding: Padding;
        private let margins: Margins;
        private let title:   String?;
        private let content: Content;

        private let radius:          CGFloat = 8;
        private let shadow:          Bool    = false;
        private let background:      Color   = Defaults.background;
        private let border:          Color?  = Defaults.foreground;
        private let borderThickness: Int     = 2;

        public init(table: Table, padding: Padding? = nil, margins: Margins? = nil,
                    title: String? = nil, @ViewBuilder content: () -> Content) {
            self.padding = Padding(padding, horizontal: 8, vertical: 8);
            self.margins = Margins(margins, horizontal: 10);
            self.title   = title;
            self.content = content();
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: 0) {
            if let title: String = title {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .frame(alignment: .leading)
                    .frame(alignment: .bottom)
                    .padding(.leading, self.margins.leading + 2)
                    .offset(y: 20)
            }
            RoundedBox(background:      self.background,
                       padding:         self.padding,
                       margins:         self.margins,
                       radius:          self.radius,
                       span:            true,
                       shadow:          self.shadow,
                       border:          self.border,
                       borderThickness: self.borderThickness) {
                self.content
            }
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
            self.margins = margins ?? Margins.fallback;
            self.foreground = foreground ?? .white;
            self.background = background ?? Defaults.foreground;
            self.weight = weight;
            self.disabled = disabled;
            self.action = action;
        }

        public var body: some View {
            RoundedBox(background: self.background, padding: self.padding, margins: self.margins) {
                Button {
                    if (!self.disabled) { Task {
                        await self.action();
                    } }
                } label: {
                    Text("join: ")
                        .font(.system(size: CGFloat(self.size), weight: self.weight))
                        .foregroundColor(self.disabled ? self.foreground.opacity(0.65) : self.foreground)
                }.buttonStyle(.plain)
                Menu {
                    ForEach(self.items.prefixes, id: \.self) { item in
                        Button(item) { self.items.select(item) }
                    }
                }
                label: {
                    Text(self.items.selected(prefix: true) ?? Defaults.emptySetChar)
                        .font(.system(size: CGFloat(self.size), weight: self.weight))
                        .foregroundColor(self.disabled ? self.foreground.opacity(0.65) : self.foreground)
                }
                .disabled(self.disabled)
            }
        }
    }

    public struct TextButton: View {

        private let text: String;
        private let size: Int;
        private let padding: Padding;
        private let margins: Margins;
        private let weight: Font.Weight;
        private let foreground: Color;
        private let background: Color;
        private let disabled: Bool;
        private let action: () async -> Void;

        public init( _ text: String,
                       size: Int? = nil, padding: Padding? = nil, margins: Margins? = nil,
                       weight: Font.Weight? = nil,
                       foreground: Color? = nil, background: Color? = nil,
                       disabled: Bool = false,
                       action: @escaping () async -> Void) {
            self.text = text;
            self.size = size ?? Defaults.fontSize;
            self.padding = padding ?? Defaults.padding;
            self.margins = margins ?? Margins.fallback;
            self.weight = weight ?? .semibold;
            self.foreground = foreground ?? .white;
            self.background = background ?? Defaults.foreground;
            self.disabled = disabled;
            self.action = action;
        }

        public var body: some View {
            Button {
                if (!self.disabled) { Task {
                    await self.action();
                } }
            } label: {
                RoundedBox(background: self.background, padding: self.padding, margins: self.margins) {
                    Text(self.text)
                        .font(.system(size: CGFloat(self.size), weight: self.weight))
                        .foregroundColor(self.disabled ? self.foreground.opacity(0.65) : self.foreground)
                }
            }
            .buttonStyle(.plain)
            .margins(self.margins)
        }
    }

    public struct IconButton: View {

        private let icon: String;
        private let size: Int;
        private let padding: Padding;
        private let margins: Margins;
        private let weight: Font.Weight;
        private let foreground: Color;
        private let background: Color;
        private let disabled: Bool;
        private let action: () async -> Void;

        public init(_ icon: String,
                       size: Int? = nil, padding: Padding? = nil, margins: Margins? = nil,
                       weight: Font.Weight? = nil,
                       foreground: Color? = nil, background: Color? = nil,
                       disabled: Bool = false,
                       action: @escaping () async -> Void) {
            self.icon = icon;
            self.size = size ?? Defaults.iconSize;
            self.padding = padding ?? Defaults.padding;
            self.margins = margins ?? Margins.fallback;
            self.weight = weight ?? .semibold;
            self.foreground = foreground ?? Defaults.iconColor;
            self.background = background ?? Defaults.foreground;
            self.disabled = disabled;
            self.action = action;
        }

        public var body: some View {
            Button {
                Task { await self.action() }
            } label: {
                Image(systemName: self.icon)
                    .foregroundColor(self.disabled ? self.foreground.opacity(0.65) : self.foreground)
                    .font(.system(size: CGFloat(self.size), weight: self.weight))
                    .disabled(self.disabled)
            }
            .buttonStyle(.plain)
            .margins(self.margins)
        }
    }

    public struct SmallButton: View {

        private let text: String?;
        private let icon: String?;
        private let color: Color;
        private let background: Color;
        private let size: Int;
        private var bold: Bool;
        private var semibold: Bool;
        private let disabled: Bool;
        private let leading: Int;
        private let trailing: Int;
        private let action: () async -> Void;

        private let horizontalPadding: CGFloat = 7;
        private let verticalPadding: CGFloat = 4;
        private let cornerRadius: CGFloat = 8

        public init( _ text: String? = nil, icon: String? = nil,
                       color: Color? = nil, background: Color? = nil,
                       size: Int? = nil, bold: Bool = false, semibold: Bool = true,
                       disabled: Bool = false,
                       leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil,
                       action: @escaping () async -> Void) {
            self.text = text;
            self.icon = icon;
            self.color = color ?? ((icon != nil) ? Defaults.iconColor : .yellow);
            self.background = background ?? Defaults.foreground;
            self.size = size ?? ((icon != nil) ? Defaults.iconSize : Defaults.fontSize);
            self.bold = bold;
            self.semibold = semibold;
            self.disabled = disabled;
            self.action = action;
            self.leading = leading ?? padding ?? 0;
            self.trailing = trailing ?? padding ?? 0;
        }

        public var body: some View {
            Button {
                Task { await action() }
            } label: {
                if let icon: String = icon {
                    Image(systemName: icon)
                        .foregroundColor(self.disabled ? .gray : color)
                        .font(.system(size: CGFloat(self.size), weight: bold ? .bold : (semibold ? .semibold : .regular)))
                        .disabled(self.disabled)
                }
                else if let text: String = text {
                    Text(text)
                        .font(.system(size: CGFloat(self.size), weight: bold ? .bold : (semibold ? .semibold : .regular)))
                        .foregroundColor(self.disabled ? .gray : self.color)
                        .padding(.horizontal, self.horizontalPadding)
                        .padding(.vertical, self.verticalPadding)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(self.background)
                        )
                        .disabled(self.disabled)
                }
            }
            .buttonStyle(.plain)
            .disabled(disabled)
            .padding(.leading, CGFloat(self.leading)).padding(.trailing, CGFloat(self.trailing))
        }
    }

    public struct RegularText: View {
        private let text: String;
        private let color: Color;
        private let size: Int;
        private var bold: Bool = false;
        private var semibold: Bool = false;
        private var strikeout: Bool = false;
        private let leading: Int;
        private let trailing: Int;
        public init(_ text: String, color: Color = .primary,
                      size: Int = Defaults.fontSize,
                      bold: Bool = false, semibold: Bool = false,
                      strikeout: Bool = false,
                      leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil) {
            self.text = text;
            self.color = color;
            self.size = size;
            self.bold = bold;
            self.semibold = semibold;
            self.strikeout = strikeout;
            self.leading = leading ?? padding ?? 0;
            self.trailing = trailing ?? padding ?? 0;
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
            Image(systemName: "arrow.triangle.2.circlepath")
                .rotationEffect(.degrees(angle))
                .font(.system(size: CGFloat(self.size - 1), weight: .semibold))
                .foregroundColor(color)
                .animation(nil, value: self.count)
                .offset(y: 0.2)
        }
    }
}
