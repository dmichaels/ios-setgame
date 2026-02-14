import SwiftUI

private struct SessionState {
    public var session: String? = nil;
    public var host: String? = nil;
    public let player: String;
    public var players: [String] = [];
    public var connected: Bool = false;
    public var leaveable: Bool = false;
    public mutating func update(from session: MultiPlayer.Session) {
        self.session = session.session;
        self.host = session.host;
        self.players = session.players;
        self.connected = session.connected;
        self.leaveable = session.leaveable;
    }
}

private struct ServerState {
    public var sessions: [String] = ["-", "ABC", "DEF", "GHI"];
    public var sessionSelected: String = "-";
}

private func SID(_ session: String?, size: Int = 4) -> String {
    return String((session ?? "∅∅∅").prefix(size));
}

public extension MultiPlayer {

    public struct DevPanel: View {

        @ObservedObject var table: Table
        @ObservedObject var settings: Settings;
                        var margin: Int = 10;

        let session: MultiPlayer.Session;
        let transport: MultiPlayer.HttpTransport;

        @State private var sessionState: SessionState;
        @State private var serverState: ServerState;
               private let poller: Poller = Poller(seconds: 2);

        public init(table: Table, settings: Settings, margin: Int) {
            self.table = table;
            self.settings = settings;
            self.margin = margin;
            let session: Session = MultiPlayer.HttpSession.instance;
            self.session = session;
            self.transport = session.transport as! MultiPlayer.HttpTransport;
            self.sessionState = SessionState(player: session.player);
            self.serverState = ServerState();
        }

        public var body: some View {
            VStack {
                DevPanelSession(table: table, session: session, transport: transport, sessionState: $sessionState, serverState: $serverState,  margin: margin)
            }
            .onAppear {
                self.poller.start({
                    self.sessionState.session = self.session.session;
                    self.sessionState.host = self.session.host;
                    self.sessionState.players = self.session.players;
                    self.sessionState.connected = self.session.connected;
                    self.sessionState.leaveable = self.session.leaveable;
                    if let sessions: [String] = await self.transport.retrieveSessions() {
                        self.serverState.sessions = sessions;
                    }
                });
            }
        }
    }

    private struct DevPanelSession: View {

        @ObservedObject var table: Table
                        let session: MultiPlayer.Session;
                        let transport: MultiPlayer.HttpTransport;
        @Binding var sessionState: SessionState;
        @Binding var serverState: ServerState;
                        var margin: Int = 10;

        let background: Color = Color(hex: 0x8BD2CC);
        let horizontalPadding: Int = 10;
        let separationPadding: Int = 0;

        let separator: String = "|" // "\u{2756}";
        let icons: Bool = true;
        let fontsize: Int = 14;
        let sid: Int = 4;

        public init(table: Table,
                    session: MultiPlayer.Session, transport: MultiPlayer.HttpTransport,
                    sessionState: Binding<SessionState>, serverState: Binding<ServerState>,
                    margin: Int) {
            self.table = table;
            self.session = session;
            self.transport = transport;
            self._sessionState = sessionState;
            self._serverState = serverState;
            self.margin = margin;
        }

        public var body: some View {
            Spacer().frame(height: CGFloat(margin))
            AnyDevPanel(table: table) {
                HStack(spacing: CGFloat(separationPadding)) {
                    RegularText("me:", size: fontsize)
                        CopyableText(text: sessionState.player,
                                     // foreground: self.info.isHost ? .red : .primary,
                                     background: self.background,
                                     bold: true,
                                     underline: true,
                                     strikeout: false,
                                     size: fontsize
                        )
                        .padding(.leading, -6)
                    RegularText("session:", size: fontsize, leading: 4)
                        CopyableText(text: SID(sessionState.session, size: sid),
                                     // foreground: self.info.isHost ? .red : .primary,
                                     background: self.background,
                                     bold: true,
                                     underline: true,
                                     strikeout: false,
                                     size: sessionState.session == nil ? 14 : 13
                        )
                        .padding(.leading, -6)
                    RegularText("p:", size: fontsize, leading: 4)
                    RegularText("\(self.sessionState.players.count)", size: fontsize, leading: 4)
                    RegularText(separator, size: fontsize, leading: 7, trailing: 10)
                    SmallButton(icons ? nil : "create", icon: icons ? "plus.rectangle.portrait" : nil, size: 17, disabled: self.sessionState.connected) {
                        if (!self.session.connected) {
                            if await self.session.create() {
                                self.sessionState.update(from: self.session);
                            }
                        }
                    }
                    RegularText("", padding: 4)
                    SmallButton(icons ? nil : "create", icon: icons ? "rectangle.portrait.and.arrow.forward" : nil, size: 16, disabled: self.sessionState.connected) {
                        if (!self.session.connected) {
                            if let session: String = findSession(items: serverState.sessions, prefix: serverState.sessionSelected) {
                                if await self.session.join(session: session) {
                                    self.sessionState.update(from: self.session);
                                }
                            }
                        }
                    }
                    RegularText("", padding: 4)
                    SmallButton(icons ? nil : "leave", icon: icons ? "xmark.rectangle.portrait" : nil, size: 17, disabled: !self.sessionState.leaveable) {
                        if (self.session.connected) {
                            if await self.session.leave() {
                                self.sessionState.update(from: self.session);
                            }
                        }
                    }
                    Spacer()
                    DropDown(items: $serverState.sessions, selected: $serverState.sessionSelected)
                }
                .padding(.horizontal, CGFloat(horizontalPadding))
            }
        }
    }
}

private struct RegularText: View {
    private let text: String;
    private let size: Int;
    private let color: Color;
    private let leading: Int;
    private let trailing: Int;
    public init(_ text: String, size: Int = 13, color: Color = .primary,
                leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil) {
        self.text = text;
        self.size = size;
        self.color = color;
        self.leading = leading ?? padding ?? 0;
        self.trailing = trailing ?? padding ?? 0;
    }
    public var body: some View {
        Text(self.text)
            .font(.system(size: CGFloat(self.size), weight: .semibold))
            .foregroundColor(self.color)
            .padding(.leading, CGFloat(self.leading)).padding(.trailing, CGFloat(self.trailing))
    }
}

private struct CopyableText: View {
    let text: String;
    var foreground: Color = .primary;
    var background: Color = .white;
    var bold: Bool = false;
    var underline: Bool = false;
    var strikeout: Bool = false;
    var size: Int = 13;
    @State private var copied = false;
    var body: some View {
        Text(text)
            .font(.system(size: CGFloat(size), weight: .semibold))
            .fontWeight(bold ? .bold : .regular)
            .underline(underline)
            .strikethrough(strikeout)
            .padding(8)
            .cornerRadius(8)
            .foregroundColor(foreground)
            .onTapGesture {
                UIPasteboard.general.string = text
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    copied = false
                }
            }
            .overlay(
                copied ? Text(" Copied ")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(6)
                    .offset(y: -40)
                    .transition(.opacity)
                    .fixedSize()
                : nil
            )
            .padding(.trailing, -4)
    }
}

public struct SmallButton: View {

    let text: String?;
    var icon: String?;
    var background: Color;
    var foreground: Color;
    var size: Int;
    var disabled: Bool;
    let action: () async -> Void;

    var cornerRadius: CGFloat = 8
    var horizontalPadding: CGFloat = 10;
    var verticalPadding: CGFloat = 4;
    
    public init(
        _ text: String? = nil,
        icon: String? = nil,
        background: Color? = nil,
        foreground: Color? = nil,
        size: Int = 13,
        disabled: Bool = false,
        action: @escaping () async -> Void
    ) {
        self.text = text;
        self.icon = icon;
        self.background = background ?? Color(hex: 0x368077);
        self.foreground = foreground ?? .yellow;
        self.size = size;
        self.disabled = disabled;
        self.action = action;
    }

    public var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            if let icon: String = icon {
                Image(systemName: icon)
                    .foregroundColor(.black)
                    .font(.system(size: CGFloat(size)))
                    .fontWeight(.semibold)
                    .disabled(disabled)
            }
            else if let text: String = text {
                Text(text)
                    .font(.system(size: CGFloat(size), weight: .semibold))
                    .foregroundColor(foreground)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(background)
                    )
                    .disabled(disabled)
            }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

private struct DropDown: View {
    
    @Binding public var items: [String];
    @Binding public var selected: String;
                    var minimize: Int = 4;
    
    public var body: some View {
        Picker(selection: $selected) {
            ForEach(minimalUniquePrefixes(self.items, min: minimize), id: \.self) { item in
                Text(item).tag(item)
            }
        } label: {
            Text(selected.isEmpty ? "Select…" : selected)
        }
        .onAppear {
            if selected.isEmpty, let first = items.first {
                selected = first
            }
        }
    }
}

private struct AnyDevPanel<Content: View>: View {

    @ObservedObject var table: Table
    private let content: Content

    var height: CGFloat = 38;
    var padding: CGFloat = 8;
    var background: Color = Color(hex: 0x8BD2CC);

    public init(
        table: Table,
        @ViewBuilder content: () -> Content
    ) {
        self.table = table
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: padding) {
            Spacer()
            HStack(alignment: .firstTextBaseline) { // .center
                content
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(background)
                    .opacity(0.8)
                    .frame(height: height)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 3, y: 6)
            )
            Spacer()
        }
    }
}

private class Poller {

    private let interval: UInt64;
    private var task: Task<Void, Never>? = nil;

    public init(seconds: Int = 2) {
        self.interval = UInt64(seconds * 1_000_000_000);
    }

    public init(milliseconds: Int = 2) {
        self.interval = UInt64(milliseconds * 1_000_000);
    }

    public func start(_ task: @escaping () async -> Void) {
        guard self.task == nil else { return }
        self.task = Task {
            while (!Task.isCancelled) {
                await task();
                try? await Task.sleep(nanoseconds: self.interval);
            }
        }
    }

    public func stop() {
        task?.cancel();
        task = nil;
    }
}


// Returns the given array of strings, which is assumed to contain UNIQUE values,
// where each value is truncated to the first, at mininum, the given minimum number
// of characters; but if not, then the prefix length will be chosen such that the
// result values will be unique. From ChatGPT wholesale.
//
private func minimalUniquePrefixes(_ items: [String], min: Int = 4) -> [String] {
    guard !items.isEmpty else { return [] }
    var result = Array(repeating: "", count: items.count)
    var prefixLength = min
    while true {
        var seen = Set<String>()
        var collision = false
        for (i, item) in items.enumerated() {
            let prefix = String(item.prefix(prefixLength))
            result[i] = prefix
            if seen.contains(prefix) {
                collision = true
            } else {
                seen.insert(prefix)
            }
        }
        if !collision {
            return result
        }
        prefixLength += 1
    }
}

private func findSession(items: [String], prefix: String) -> String? {
    return items.first { $0.hasPrefix(prefix) };
}
