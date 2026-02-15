import SwiftUI

private struct SessionState {
    public var session: String? = nil;
    public var host: String? = nil;
    public let player: String;
    public var hosting: Bool { self.player == (self.host ?? "") }
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
    fileprivate var sessionList: SessionList = SessionList();
}

// All this nonesense is just so we can reliably deal with (view) the session IDs as short values.
//
private struct SessionList {

    private static           let shortLengthDefault: Int = 4;
    private                  var sessions: [String] = [];
    fileprivate private(set) var sessionsShort: [String] = [];
    fileprivate              var selected: String? { return self.sessions.first { $0.hasPrefix(self.selectedShort) }; }
    fileprivate              var selectedShort: String = "";
    private                  var shortLength: Int = SessionList.shortLengthDefault;

    fileprivate init(_ sessions: [String] = []) {
        self.update(sessions);
    }

    fileprivate mutating func select(_ session: String?) {
        if let session: String = session {
            if (!self.sessions.contains(session)) {
                self.sessions.append(session);
            }
            self.selectedShort = self.shorten(session);
        }
    }

    fileprivate mutating func update(_ sessions: [String]) {
        self.sessions = sessions;
        (self.sessionsShort, self.shortLength) = SessionList.shortenValues(sessions);
        if let session: String = self.sessions.first {
            self.select(session);
        }
    }

    fileprivate func shorten(_ session: String?, fallback: String = "") -> String {
        if let session: String = session {
            return String(session.prefix(self.shortLength));
        }
        return fallback;
    }

    // Returns the given array of strings, which is assumed to contain UNIQUE values,
    // where each value is truncated to the first, at mininum, the given minimum number
    // of characters; but if not, then the prefix length will be chosen such that the
    // result values will be unique. From ChatGPT wholesale.
    //
    private static func shortenValues(_ list: [String]) -> (list: [String], shortLength: Int) {
        guard !list.isEmpty else { return (list: [], shortLength: SessionList.shortLengthDefault) }
        var result = Array(repeating: "", count: list.count); var prefixLength = SessionList.shortLengthDefault;
        while (true) {
            var seen = Set<String>(); var collision = false;
            for (i, item) in list.enumerated() {
                let prefix = String(item.prefix(prefixLength)); result[i] = prefix;
                if (seen.contains(prefix)) { collision = true } else { seen.insert(prefix); }
            }
            if (!collision) { return (list: result, shortLength: prefixLength); } ; prefixLength += 1;
        }
    }
}

public extension MultiPlayer {

    public struct DevPanel: View {

        @ObservedObject private var table: Table
        @ObservedObject private var settings: Settings;
                        private var margin: Int = 10;

                        private let session: MultiPlayer.Session;
                        private let transport: MultiPlayer.HttpTransport;
                 @State private var sessionState: SessionState;
                 @State private var serverState: ServerState;
                        private let poller: Poller;

        fileprivate static let background: Color = Color(hex: 0x8BD2CC);
        fileprivate static let foreground: Color = Color(hex: 0x028433);
        fileprivate static let horizontalPadding: Int = 5;
        fileprivate static let separationPadding: Int = 0;
        fileprivate static let fontsize: Int = 14;
        fileprivate static let separator: String = "|" // "\u{2756}";
        fileprivate static let icons: Bool = false;

        public init(table: Table, settings: Settings, margin: Int = 0) {
            self.table = table;
            self.settings = settings;
            self.margin = margin;
            let session: Session = MultiPlayer.HttpSession.instance;
            self.session = session;
            self.transport = session.transport as! MultiPlayer.HttpTransport;
            self.sessionState = SessionState(player: session.player);
            self.serverState = ServerState();
            self.poller = Poller(seconds: 2);
        }

        public var body: some View {
            VStack {
                DevPanelInfo(table: table, session: session, transport: transport, sessionState: $sessionState, serverState: $serverState, margin: margin)
                DevPanelSession(table: table, session: session, transport: transport, sessionState: $sessionState, serverState: $serverState, margin: 16)
            }
            .onAppear {
                self.poller.start({
                    self.sessionState.update(from: self.session);
                    // TODO: does not work - await self.serverState.update(from: self.transport);
                    if let sessions: [String] = await self.transport.retrieveSessions() {
                        self.serverState.sessionList.update(sessions.reversed());
                    }
                });
            }
            .onDisappear {
                self.poller.stop();
            }
        }
    }

    private struct DevPanelInfo: View {

        @ObservedObject private var table: Table
                        private let session: MultiPlayer.Session;
                        private let transport: MultiPlayer.HttpTransport;
               @Binding private var sessionState: SessionState;
               @Binding private var serverState: ServerState;
                        private let margin: Int;

        fileprivate init(table: Table,
                         session: MultiPlayer.Session, transport: MultiPlayer.HttpTransport,
                         sessionState: Binding<SessionState>, serverState: Binding<ServerState>,
                         margin: Int = 10) {
            self.table = table;
            self.session = session;
            self.transport = transport;
            self._sessionState = sessionState;
            self._serverState = serverState;
            self.margin = margin;
        }

        fileprivate var body: some View {
            Spacer().frame(height: CGFloat(margin))
            AnyDevPanel(table: table) {
                HStack(spacing: CGFloat(DevPanel.separationPadding)) {
                    RegularText("me:", size: DevPanel.fontsize)
                        CopyableText(text: sessionState.player,
                                     foreground: session.hosting ? .red : .primary,
                                     background: DevPanel.background,
                                     bold: true,
                                     underline: false,
                                     strikeout: false,
                                     size: DevPanel.fontsize
                        )
                        .padding(.leading, -6)
                    RegularText("session:", size: DevPanel.fontsize, leading: 4)
                        CopyableText(text: serverState.sessionList.shorten(sessionState.session, fallback: "∅"),
                                     // foreground: self.info.isHost ? .red : .primary,
                                     background: DevPanel.background,
                                     bold: true,
                                     underline: false,
                                     strikeout: false,
                                     size: sessionState.session == nil ? 14 : 13
                        )
                        .padding(.leading, -6)
                    RegularText("host:", size: DevPanel.fontsize, leading: 4)
                    RegularText("\(self.sessionState.host ?? "∅")", size: DevPanel.fontsize, color: session.hosting ? .red : .primary, leading: 4)
                    RegularText("players:", size: DevPanel.fontsize, leading: 8)
                    RegularText("\(self.sessionState.players.count == 0 ? "∅" : "\(self.sessionState.players.count)")", size: DevPanel.fontsize, leading: 4)
                    Spacer()
                }
                .padding(.horizontal, CGFloat(DevPanel.horizontalPadding))
            }
        }
    }

    private struct DevPanelSession: View {

        @ObservedObject private var table: Table
                        private let session: MultiPlayer.Session;
                        private let transport: MultiPlayer.HttpTransport;
               @Binding private var sessionState: SessionState;
               @Binding private var serverState: ServerState;
                        private let margin: Int;

        fileprivate init(table: Table,
                         session: MultiPlayer.Session, transport: MultiPlayer.HttpTransport,
                         sessionState: Binding<SessionState>, serverState: Binding<ServerState>,
                         margin: Int = 10) {
            self.table = table;
            self.session = session;
            self.transport = transport;
            self._sessionState = sessionState;
            self._serverState = serverState;
            self.margin = margin;
        }

        fileprivate var body: some View {
            Spacer().frame(height: CGFloat(margin))
            AnyDevPanel(table: table) {
                HStack(spacing: CGFloat(DevPanel.separationPadding)) {
                    RegularText("session:", size: DevPanel.fontsize, leading: 4)
                        CopyableText(text: serverState.sessionList.shorten(sessionState.session, fallback: "∅"),
                                     // foreground: self.info.isHost ? .red : .primary,
                                     background: DevPanel.background,
                                     bold: true,
                                     underline: false,
                                     strikeout: false,
                                     size: sessionState.session == nil ? 14 : 13
                        )
                        .padding(.leading, -6)
                    RegularText("", size: DevPanel.fontsize, leading: 7, trailing: 1)
                    SmallButton(DevPanel.icons ? nil : "create", icon: DevPanel.icons ? "plus.rectangle.portrait" : nil, disabled: self.sessionState.connected) {
                        if (!self.session.connected) {
                            if await self.session.create() {
                                self.sessionState.update(from: self.session);
                                self.serverState.sessionList.select(self.session.session);
                            }
                        }
                    }
                    RegularText("", padding: 4)
                    SmallButton(DevPanel.icons ? nil : "join", icon: DevPanel.icons ? "rectangle.portrait.and.arrow.forward" : nil, disabled: self.sessionState.connected) {
                        if (!self.session.connected) {
                            if let session: String = serverState.sessionList.selected {
                                if await self.session.join(session: session) {
                                    self.sessionState.update(from: self.session);
                                }
                            }
                        }
                    }
                    RegularText("", padding: 4)
                    DropDown(items: serverState.sessionList.sessionsShort,
                             selected: $serverState.sessionList.selectedShort)
                    Spacer()
                    SmallButton(DevPanel.icons ? nil : "host",
                                icon: DevPanel.icons ? "xmark.rectangle.portrait" : nil,
                                disabled: !self.sessionState.connected || self.sessionState.hosting) {
                        if (self.session.connected) {
                            if await self.session.requestHost() {
                                self.sessionState.update(from: self.session);
                            }
                        }
                    }
                    RegularText("", padding: 4)
                    SmallButton(/*DevPanel.icons*/ true ? nil : "leave", icon: /*DevPanel.icons*/ true ? "xmark.rectangle.portrait" : nil, size: 20, disabled: !self.sessionState.leaveable) {
                        if (self.session.connected) {
                            if await self.session.leave() {
                                self.sessionState.update(from: self.session);
                            }
                        }
                    }
                }
                .padding(.horizontal, CGFloat(DevPanel.horizontalPadding))
            }
        }
    }

    private struct RegularText: View {
        private let text: String;
        private let size: Int;
        private let color: Color;
        private let leading: Int;
        private let trailing: Int;
        fileprivate init(_ text: String, size: Int = 13, color: Color = .primary,
                           leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil) {
            self.text = text;
            self.size = size;
            self.color = color;
            self.leading = leading ?? padding ?? 0;
            self.trailing = trailing ?? padding ?? 0;
        }
        fileprivate var body: some View {
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
                    UIPasteboard.general.string = text;
                    copied = true;
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
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

    private struct SmallButton: View {

        private let text: String?;
        private let icon: String?;
        private let background: Color;
        private let foreground: Color;
        private let size: Int;
        private let disabled: Bool;
        private let action: () async -> Void;

        private let cornerRadius: CGFloat = 8
        private let horizontalPadding: CGFloat = 6;
        private let verticalPadding: CGFloat = 3;
    
        public init( _ text: String? = nil, icon: String? = nil,
                       background: Color? = nil, foreground: Color? = nil, size: Int = 14,
                       disabled: Bool = false, action: @escaping () async -> Void) {
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
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(background)
                        )
                        .disabled(disabled)
                }
            }
            .buttonStyle(.plain)
            .disabled(disabled)
        }
    }

    private struct DropDown: View {
                 fileprivate var items: [String];
        @Binding fileprivate var selected: String;
        fileprivate var body: some View {
            Menu {
                ForEach(items, id: \.self) { item in
                    Button(item) { selected = item }
                }
            } label: {
                Text(selected.isEmpty ? (items.first ?? "SELECT") : selected)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DevPanel.foreground)
            }
            .offset(y: 2)
            .onAppear {
                if selected.isEmpty, let first = items.first {
                    selected = first;
                }
            }
        }
    }

    private struct AnyDevPanel<Content: View>: View {

        @ObservedObject private var table: Table;
                        private let content: Content;

        private var height: CGFloat = 38;
        private var padding: CGFloat = 8;
        private var background: Color = Color(hex: 0x8BD2CC);

        fileprivate init( table: Table, @ViewBuilder content: () -> Content) {
            self.table = table;
            self.content = content();
        }

        fileprivate var body: some View {
            HStack(spacing: padding) {
                Spacer()
                HStack(alignment: .firstTextBaseline) {
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
        fileprivate init(seconds: Int = 2) {
            self.interval = UInt64(seconds * 1_000_000_000);
        }
        fileprivate func start(_ task: @escaping () async -> Void) {
            guard self.task == nil else { return }
            self.task = Task {
                while (!Task.isCancelled) {
                    await task();
                    try? await Task.sleep(nanoseconds: self.interval);
                }
            }
        }
        fileprivate func stop() {
            task?.cancel();
            task = nil;
        }
    }
}
