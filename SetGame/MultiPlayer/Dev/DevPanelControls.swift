import SwiftUI

public extension MultiPlayer.Dev {

    public struct AnyDevPanel<Content: View>: View {

        @ObservedObject private var table: Table;
                        private let background: Color;
                        private let leadingPadding: Int;
                        private let verticalPadding: Int;
                        private let topMargin: Int;
                        private let horizontalMargin: Int;
                        private let content: Content;

        public init(table: Table, background: Color = Defaults.background,
                    leading: Int = 8,
                    vertical: Int = 3,
                    margin: Int = 0,
                    hmargin: Int = 4, @ViewBuilder content: () -> Content) {
            self.table = table;
            self.background = background;
            self.leadingPadding = leading;
            self.verticalPadding = vertical;
            self.topMargin = margin;
            self.horizontalMargin = hmargin;
            self.content = content();
        }

        public var body: some View {
            if (self.topMargin > 0) { Spacer().frame(height: CGFloat(self.topMargin)) }
            HStack(spacing: CGFloat(self.horizontalMargin)) {
                Spacer()
                HStack(alignment: .firstTextBaseline) {
                    VStack() {
                        Spacer().frame(height: CGFloat(self.verticalPadding))
                        HStack(spacing: 0) {
                            content
                        }.padding(.leading, CGFloat(self.leadingPadding))
                        Spacer().frame(height: CGFloat(self.verticalPadding - 1))
                    }
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(background)
                        .opacity(0.8)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 3, y: 6)
                )
                Spacer()
            }
        }
    }

    public struct JoinControl: View {

                 fileprivate let items: [String];
        @Binding fileprivate var selected: String;
                 fileprivate let size: Int = Defaults.fontSize;
                 fileprivate let disabled: Bool;
                 fileprivate let leading: Int;
                 fileprivate let trailing: Int;
                 fileprivate let action: () async -> Void;

        private let horizontalPadding: CGFloat = 8;
        private let verticalPadding: CGFloat = 4;
        private let cornerRadius: CGFloat = 8;
        private let color: Color = .yellow;
        private let background: Color = Defaults.foreground;
        private let foregroundDisabled: Color = .gray;

        public init(items: [String], selected: Binding<String>, disabled: Bool = false,
                    leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil,
                    action: @escaping () async -> Void) {
            self.items = items;
            self._selected = selected;
            self.disabled = disabled;
            self.leading = leading ?? padding ?? 0;
            self.trailing = trailing ?? padding ?? 0;
            self.action = action;
        }

        public var body: some View {
            HStack(spacing: 0) {
                Button {
                    Task { await action() }
                } label: {
                    Text("join:")
                        .font(.system(size: CGFloat(self.size), weight: .semibold))
                        .foregroundColor(disabled ? self.color.opacity(0.4) : self.color)
                        .padding(.leading, self.horizontalPadding)
                        .padding(.vertical, self.verticalPadding)
                }
                .buttonStyle(.plain)
                Rectangle().fill(self.color.opacity(0.4)).frame(width: 3, height: 1)
                Menu {
                    ForEach(items, id: \.self) { item in
                        Button(item) { selected = item }
                    }
                } label: {
                    Text(selected.isEmpty ? (items.first ?? Defaults.emptySetChar) : selected)
                        .font(.system(size: CGFloat(self.size - 1)))
                        .foregroundColor(disabled ? self.color.opacity(0.4) : self.color)
                        .padding(.trailing, self.horizontalPadding)
                        .padding(.vertical, self.verticalPadding)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(disabled ? self.background.opacity(0.4) : self.background)
            )
            .onAppear {
                if selected.isEmpty, let first = items.first {
                    selected = first;
                }
            }
            .padding(.leading, CGFloat(self.leading)).padding(.trailing, CGFloat(self.trailing))
        }
    }

    public struct SmallButton: View {

        private let text: String?;
        private let icon: String?;
        private let color: Color;
        private let background: Color;
        private let size: Int;
        private let disabled: Bool;
        private let leading: Int;
        private let trailing: Int;
        private let action: () async -> Void;

        private let horizontalPadding: CGFloat = 7;
        private let verticalPadding: CGFloat = 4;
        private let cornerRadius: CGFloat = 8

        public init( _ text: String? = nil, icon: String? = nil,
                       color: Color? = nil, background: Color? = nil,
                       size: Int? = nil, disabled: Bool = false,
                       leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil,
                       action: @escaping () async -> Void) {
            self.text = text;
            self.icon = icon;
            self.color = color ?? ((icon != nil) ? Defaults.iconColor : .yellow);
            self.background = background ?? Defaults.foreground;
            self.size = size ?? ((icon != nil) ? Defaults.iconSize : Defaults.fontSize);
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
                        .foregroundColor(color)
                        .font(.system(size: CGFloat(self.size)))
                        .fontWeight(.semibold)
                        .disabled(self.disabled)
                }
                else if let text: String = text {
                    Text(text)
                        .font(.system(size: CGFloat(self.size), weight: .semibold))
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
