import SwiftUI

private struct Const {
    fileprivate static let background: Color = Color(hex: 0x77BBAA);
    fileprivate static let foreground: Color = Color(hex: 0x226655);
    fileprivate static let fontSize: Int = 15;
    fileprivate static let separator: String = "|" // "\u{2756}";
    fileprivate static let emptySetChar: String = "∅";
    fileprivate static let checkChar: String = "✓";
    fileprivate static let xmarkChar: String = "✗";
    fileprivate static let leftArrowChar: String = "◀ ";
    fileprivate static let highlightColor: Color = Color(hex: 0x882211);
}

private struct SessionState {

    // Readonly properties (from external POV).
    //
    fileprivate private(set) var session: String? = nil;
    fileprivate private(set) var host: String? = nil;
    fileprivate              let player: String;
    fileprivate              var hosting: Bool { self.player == (self.host ?? "") }
    fileprivate private(set) var players: [String] = [];
    fileprivate private(set) var connected: Bool = false;
    fileprivate private(set) var leaveable: Bool = false;
    fileprivate private(set) var pingable: Bool = false;
    fileprivate private(set) var info: Json = [:];
    fileprivate              var sessionShort: String { self.sessions.shorten(self.session ?? Const.emptySetChar) }
    fileprivate private(set) var polling: Bool = false;
    fileprivate private(set) var pollCount: Int = 0;

    // Read/write properties (from external POV).
    //
    fileprivate var debug: Bool = false;
    fileprivate var production: Bool = false;
    fileprivate var sessions: SessionList = SessionList();

    // Inaccessible properties (from external POV).
    //
    private var poller: Poller;
    private var pollerAction: (() async -> Void)? = nil;

    fileprivate init(player: String, pollInterval: Int) {
        self.player = player;
        poller = Poller(milliseconds: pollInterval);
    }

    fileprivate mutating func poll(enable: Bool) {
        if (enable) {
            if let pollerAction = self.pollerAction {
                self.polling = true;
                self.poller.start(pollerAction);
            }
        }
        else {
            self.polling = false;
            self.poller.stop();
        }
    }

    fileprivate mutating func poll(_ action: (@escaping () async -> Void)) {
        self.pollerAction = action;
        self.polling = true;
        self.poller.start(action);
    }

    fileprivate func nopoll() {
        self.poller.stop();
    }

    public mutating func update(from session: MultiPlayer.Session) {
        self.session = session.session;
        self.host = session.host;
        self.players = session.players;
        self.connected = session.connected;
        self.leaveable = session.leaveable;
    }

    public mutating func update(from session: MultiPlayer.Session,
                                info: Json?,
                                sessions: [String]?,
                                pingable: Bool,
                                production: Bool,
                                debug: Bool) {
        self.update(from: session);
        self.pingable = pingable;
        self.debug = debug;
        self.pollCount = self.poller.count;
        if let info: Json = info {
            self.info = info;
        }
        if let sessions: [String] = sessions {
            self.sessions.update(sessions.reversed());
        }
    }

    fileprivate class Poller {
        private let interval: UInt64;
        private var task: Task<Void, Never>? = nil;
        fileprivate private(set) var count: Int = 0;
        fileprivate init(seconds: Int = 1) {
            self.interval = UInt64(seconds * 1_000_000_000);
        }
        fileprivate init(milliseconds: Int = 1) {
            self.interval = UInt64(milliseconds * 1_000_000);
        }
        fileprivate func start(_ task: @escaping () async -> Void) {
            guard self.task == nil else { return }
            self.task = Task {
                while (!Task.isCancelled) {
                    self.count += 1;
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

    fileprivate struct SessionList {

        private static           let shortLengthDefault: Int = 4;
        private                  var sessions: [String] = [];
        fileprivate private(set) var sessionsShort: [String] = [];
        fileprivate              var selected: String? { return self.sessions.first { $0.hasPrefix(self.selectedShort) }; }
        fileprivate              var selectedShort: String = "";
        private                  var shortLength: Int = SessionList.shortLengthDefault;

        fileprivate init(_ sessions: [String] = []) {
            self.update(sessions);
        }

        fileprivate func contains(_ session: String?) -> Bool {
            return (session != nil) && self.sessions.contains(session!) ? true : false;
        }

        fileprivate mutating func select(_ session: String?) {
            if let session: String = session {
                if (!self.sessions.contains(session)) {
                    self.sessions.append(session);
                }
                self.selectedShort = self.shorten(session);
            }
            else {
                self.selectedShort = "";
            }
        }

        fileprivate mutating func update(_ sessions: [String]) {
            self.sessions = sessions;
            (self.sessionsShort, self.shortLength) = SessionList.shortenValues(sessions);
            if let session: String = self.sessions.first {
                self.select(session);
            }
            else {
                self.select(nil);
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
}

public extension MultiPlayer {

    public struct DevPanel: View {

        @ObservedObject private var table: Table
        @ObservedObject private var settings: Settings;
                        private var margin: Int = 10;

                 @State private var sessionState: SessionState;
                        private let pollInterval: Int = 500;

        private var session: MultiPlayer.Session { MultiPlayer.HttpSession.instance }
        private var transport: MultiPlayer.Transport { MultiPlayer.HttpSession.instance.transport as! MultiPlayer.HttpTransport }

        public init(table: Table, settings: Settings, margin: Int = 0) {
            self.table = table;
            self.settings = settings;
            self.margin = margin;
            self.sessionState = SessionState(player: MultiPlayer.HttpSession.instance.player,
                                             pollInterval: pollInterval);
                                             // poller: SessionState.Poller(milliseconds: pollInterval));
        }

        public var body: some View {
            VStack {
                DevPanelInfo(table: table, session: session, transport: transport, sessionState: $sessionState, margin: margin)
                DevPanelSession(table: table, session: session, transport: transport, sessionState: $sessionState, margin: 12)
                DevPanelPlayers(table: table, session: session, transport: transport, sessionState: $sessionState, margin: 12)
                DevPanelMessages(table: table, session: session, transport: transport, sessionState: $sessionState, margin: 12)
                DevPanelServer(table: table, session: session, transport: transport, sessionState: $sessionState, margin: 12)
            }
            .onAppear { self.sessionState.poll({
                self.sessionState.update(from: self.session,
                                         info: await self.transport.session(self.session.session),
                                         sessions: await self.transport.sessions(),
                                         pingable: await self.transport.ping(),
                                         production: transport.production,
                                         debug: await transport.debug(enable: nil));
                if let session: String = self.session.session, !self.sessionState.sessions.contains(session) {
                    //
                    // Our connected session seems to have disappeared out from under us;
                    // can happen in dev/testing; disconnect our session object et cetera.
                    //
                    self.session.disconnect();
                }
            })}
            .onDisappear { self.sessionState.poll(enable: false) }
        }
    }

    private struct DevPanelInfo: View {

        @ObservedObject private var table: Table
                        private let session: MultiPlayer.Session;
                        private let transport: MultiPlayer.Transport;
               @Binding private var sessionState: SessionState;
                        private let margin: Int;

        fileprivate init(table: Table,
                         session: MultiPlayer.Session, transport: MultiPlayer.Transport,
                         sessionState: Binding<SessionState>, margin: Int = 10) {
            self.table = table;
            self.session = session;
            self.transport = transport;
            self._sessionState = sessionState;
            self.margin = margin;
        }

        fileprivate var body: some View {
            AnyDevPanel(table: table, margin: margin) {
                RegularText("me:")
                    CopyableText(sessionState.player,
                                 color: self.session.hosting ? Const.highlightColor : .primary, semibold: true, leading: 3)
                RegularText("host:", leading: 10)
                    CopyableText("\(self.sessionState.host ?? Const.emptySetChar)",
                                 color: self.session.hosting ? Const.highlightColor : .primary, semibold: true, leading: 3)
                RegularText("players:", leading: 10)
                    RegularText("\(self.sessionState.players.count == 0 ? Const.emptySetChar : "\(self.sessionState.players.count)")", leading: 3)
                Spacer()
                SmallButton(icon: self.transport.engaged ? "pause.circle" : "play.circle", disabled: !self.sessionState.connected) {
                    /*
                    if let messagesReceived: [HttpTransport.MessageReceived] = HttpTransport.messagesReceived(info: self.sessionState.info, player: self.session.player) {
                        for message in messagesReceived {
                            print("XYZZY-MESSAGE(\(self.session.player): \(message.message.type)")
                        }
                    }
                    */
                    if (self.transport.engaged) {
                        self.transport.disengage();
                    }
                    else {
                        self.transport.engage();
                    }
                }
            }
        }
    }

    private struct DevPanelSession: View {

        @ObservedObject private var table: Table
                        private let session: MultiPlayer.Session;
                        private let transport: MultiPlayer.Transport;
               @Binding private var sessionState: SessionState;
                        private let margin: Int;

        fileprivate init(table: Table,
                         session: MultiPlayer.Session, transport: MultiPlayer.Transport,
                         sessionState: Binding<SessionState>, margin: Int = 10) {
            self.table = table;
            self.session = session;
            self.transport = transport;
            self._sessionState = sessionState;
            self.margin = margin;
        }

        fileprivate var body: some View {
            AnyDevPanel(table: table, vertical: 8, margin: margin) {
                RegularText("session:")
                    CopyableText(sessionState.sessionShort, copy: sessionState.session, bold: true, leading: 3)
                SmallButton("create", disabled: self.sessionState.connected, leading: 8) {
                    if (!self.session.connected) {
                        if await self.session.create() {
                            self.sessionState.update(from: self.session);
                            self.sessionState.sessions.select(self.session.session);
                        }
                    }
                }
                JoinControl(items: sessionState.sessions.sessionsShort,
                            selected: $sessionState.sessions.selectedShort,
                            disabled: self.sessionState.connected, leading: 8) {
                    if (!self.session.connected) {
                        if let session: String = sessionState.sessions.selected {
                            if await self.session.join(session: session) {
                                self.sessionState.update(from: self.session);
                                //
                                // TODO: Do something if join-session fails?
                                //
                            }
                        }
                    }
                }
                Spacer()
                SmallButton("host", disabled: !self.sessionState.connected || self.sessionState.hosting) {
                    if (self.session.connected) {
                        if await self.session.requestHost() {
                            self.sessionState.update(from: self.session);
                            //
                            // TODO: Do something if request-host fails?
                            //
                        }
                    }
                }
                RegularText("", padding: 2)
                SmallButton(icon: "xmark.rectangle.portrait", disabled: !self.sessionState.leaveable) {
                    if let info = await self.transport.session(self.session.session) {
                        let (sent, queued, received) = HttpTransport.messageCounts(info: info, player: self.session.player);
                    }
                    if (self.session.connected) {
                        if await self.session.leave() {
                            self.sessionState.update(from: self.session);
                            //
                            // TODO: Do something if leave-session fails?
                            //
                        }
                    }
                }
            }
        }
    }

    private struct DevPanelPlayers: View {

        @ObservedObject private var table: Table
                        private let session: MultiPlayer.Session;
                        private let transport: MultiPlayer.Transport;
               @Binding private var sessionState: SessionState;
                        private let margin: Int;

        fileprivate init(table: Table,
                         session: MultiPlayer.Session, transport: MultiPlayer.Transport,
                         sessionState: Binding<SessionState>, margin: Int = 10) {
            self.table = table;
            self.session = session;
            self.transport = transport;
            self._sessionState = sessionState;
            self.margin = margin;
        }

        fileprivate var body: some View {
            AnyDevPanel(table: table, margin: margin) {
                PlayersView(players: self.sessionState.players,
                            player: self.sessionState.player,
                            host: self.sessionState.host ?? "",
                            info: self.sessionState.info)
            }
        }

        private struct PlayersView: View {

            private let players: [String];
            private let player: String;
            private let host: String;
            private let noplayers: Bool;
            private var sent: [String: Int] = [:];
            private var received: [String: Int] = [:];
            private var queued: [String: Int] = [:];
            private let size: Int;

            fileprivate init(players: [String], player: String, host: String, info: Json, size: Int = Const.fontSize) {
                self.noplayers = (players.count == 0);
                self.player = player;
                self.players = (players.count == 0) ? [player] : players;
                self.host = host;
                for player in players {
                    let (sent, queued, received) = HttpTransport.messageCounts(info: info, player: player)
                    self.sent[player] = sent;
                    self.queued[player] = queued;
                    self.received[player] = received;
                }
                self.size = size;
            }

            fileprivate var body: some View {
                VStack(spacing: 4) {
                    HStack {
                        Text("player").bold().frame(maxWidth: .infinity, alignment: .leading)
                        Text("sent").frame(width: 40, alignment: .trailing)
                        Text("received").frame(width: 70, alignment: .trailing)
                        Text("queued").frame(width: 60, alignment: .trailing)
                    }
                    ForEach(Array(players.enumerated()), id: \.element) { index, player in
                        if index == 0 {
                            Rectangle()
                                .fill(Color.black)
                                .frame(height: 2 / UIScreen.main.scale)
                                .offset(y: 0.5)
                        }
                        HStack {
                            Text(player + (player == self.player ? " ◀" : ""))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(player == self.host ? Const.highlightColor : Color.primary)
                            Text(self.noplayers ? Const.emptySetChar : "\(sent[player] ?? 0)")
                                .frame(width: 40, alignment: .trailing)
                            Text(self.noplayers ? Const.emptySetChar : "\(received[player] ?? 0)")
                                .frame(width: 70, alignment: .trailing)

                            Text(self.noplayers ? Const.emptySetChar : "\(queued[player] ?? 0)")
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(.vertical, 2)
                        if index < players.count - 1 {
                            Rectangle()
                                . fill(Color.black)
                                .frame(height: 2 / UIScreen.main.scale)
                                .offset(y: 0.5)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: CGFloat(self.size), weight: .semibold))
            }
        }
    }

    private struct DevPanelMessages: View {

        @ObservedObject private var table: Table
                        private let session: MultiPlayer.Session;
                        private let transport: MultiPlayer.Transport;
               @Binding private var sessionState: SessionState;
                        private let margin: Int;

        fileprivate init(table: Table,
                         session: MultiPlayer.Session, transport: MultiPlayer.Transport,
                         sessionState: Binding<SessionState>, margin: Int = 10) {
            self.table = table;
            self.session = session;
            self.transport = transport;
            self._sessionState = sessionState;
            self.margin = margin;
        }

        fileprivate var body: some View {
            AnyDevPanel(table: table, vertical: 5, margin: margin) {
                MessagesView(sessionState: $sessionState)
            }
        }

        private struct MessagesView: View {

            @Binding public  var sessionState: SessionState;
                     private let size: Int = Const.fontSize;

            @State private var verbose: Bool = false;

            fileprivate init(sessionState: Binding<SessionState>) {
                self._sessionState = sessionState;
            }

            private var player: String {
                return sessionState.player;
            }

            private var players: [String] {
                return sessionState.players;
            }

            private var messages: [String: [HttpTransport.MessageReceived]] {
                var result: [String: [HttpTransport.MessageReceived]] = [:]
                if (verbose) {
                    for player in sessionState.players {
                        if let received = HttpTransport.messagesReceived(info: sessionState.info, player: player) {
                            result[player] = received;
                        }
                    }
                }
                else {
                    if let received = HttpTransport.messagesReceived(info: sessionState.info, player: sessionState.player) {
                        result[sessionState.player] = received;
                    }
                }
                return result
            }

            private static func messageType(_ message: Message) -> String {
                switch message.type {
                    case .ping:                 return "ping";
                    case .joinSession:          return "join";
                    case .joinSessionConfirmed: return "joined";
                    case .leaveSession:         return "leave";
                    case .requestHostSession:   return "host";
                    case .updateSession:        return "update";
                    case .newGame:              return "new-game";
                    case .setFound:             return "set-found";
                    case .setConfirmed:         return "set-confirm";
                    case .setMissed:            return "set-missed";
                }
            }

            private var columns: [GridItem] {[
                GridItem(.fixed(90), alignment: .leading),  // player
                GridItem(.flexible(), alignment: .leading), // received
                GridItem(.fixed(70), alignment: .leading),  // host
                GridItem(.fixed(95), alignment: .leading)   // time
            ]}

            fileprivate var body: some View {
                VStack(spacing: 4) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 4) {
                        HStack {
                            Text("player").bold()
                            SmallButton(icon: verbose ? "arrow.down.square" : "arrow.up.square" , size: 16) {
                                self.verbose.toggle();
                            }
                        }
                        Text("received").bold()
                        Text("host").bold()
                        Text("time").bold()
                    }
                    Rectangle().fill(Color.black).frame(height: 2 / UIScreen.main.scale)
                    ForEach(self.players, id: \.self) { player in
                        if let received: [HttpTransport.MessageReceived] = self.messages[player] {
                            LazyVGrid(columns: columns, alignment: .leading, spacing: 4) {
                                Text(player + (player == self.player ? " \(Const.leftArrowChar)" : ""))
                                     .font(.system(size: 13, weight: .semibold))
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(received, id: \.id) { message in
                                        Text("\(MessagesView.messageType(message.message))")
                                            .font(.system(size: 13, weight: .regular))
                                            .lineLimit(1)
                                    }
                                }
                                .frame(maxHeight: .infinity, alignment: .topLeading)
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(received, id: \.id) { message in
                                        Text("\(message.host)")
                                            .font(.system(size: 13, weight: .regular))
                                    }
                                }
                                .frame(maxHeight: .infinity, alignment: .topLeading)
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(received, id: \.id) { message in
                                        Text("\(message.timestamp)")
                                            .font(.system(size: 13, weight: .regular))
                                    }
                                }
                                .frame(maxHeight: .infinity, alignment: .topLeading)
                            }
                            Rectangle().fill(Color.black).frame(height: 2 / UIScreen.main.scale)
                        }
                    }
                }
                .font(.system(size: CGFloat(self.size), weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private struct DevPanelServer: View {

        @ObservedObject private var table: Table
                        private let session: MultiPlayer.Session;
                        private let transport: MultiPlayer.Transport;
               @Binding private var sessionState: SessionState;
                        private let margin: Int;

        fileprivate init(table: Table,
                         session: MultiPlayer.Session, transport: MultiPlayer.Transport,
                         sessionState: Binding<SessionState>, margin: Int = 10) {
            self.table = table;
            self.session = session;
            self.transport = transport;
            self._sessionState = sessionState;
            self.margin = margin;
        }

        fileprivate var body: some View {
            AnyDevPanel(table: table, vertical: 2, margin: margin) {
                HStack {
                    RegularText("server: ", size: 13)
                        RegularText(transport.server, color: self.sessionState.pingable ? .primary : Const.highlightColor, size: 13, bold: true, leading: -4)
                            RegularText(self.sessionState.pingable ? Const.checkChar : Const.xmarkChar,
                                        color: self.sessionState.pingable ? .primary : Const.highlightColor,
                                        size: 13, bold: true, leading: 2)
                    RegularText("(\(self.sessionState.pollCount))", size: 10)
                    Spacer()
                    SmallButton(icon: self.sessionState.polling ? "pause.circle" : "play.circle", size: 17) {
                        self.sessionState.poll(enable: !self.sessionState.polling);
                    }
                    SmallButton(icon: self.sessionState.production ? "checkmark.seal" : "atom", size: 16) {
                        await self.transport.production = !self.sessionState.production;
                    }
                    SmallButton(icon: self.sessionState.debug ? "ladybug" : "ladybug.slash", size: 16) {
                        await self.transport.debug(enable: !self.sessionState.debug);
                    }
                }
            }
        }
    }

    private struct AnyDevPanel<Content: View>: View {

        @ObservedObject private var table: Table;
                        private let background: Color;
                        private let leadingPadding: Int;
                        private let verticalPadding: Int;
                        private let topMargin: Int;
                        private let horizontalMargin: Int;
                        private let content: Content;

        fileprivate init(table: Table, background: Color = Const.background,
                                       leading:    Int = 8,
                                       vertical:   Int = 3,
                                       margin:     Int = 0,
                                       hmargin:    Int = 4, @ViewBuilder content: () -> Content) {
            self.table = table;
            self.background = background;
            self.leadingPadding = leading;
            self.verticalPadding = vertical;
            self.topMargin = margin;
            self.horizontalMargin = hmargin;
            self.content = content();
        }

        fileprivate var body: some View {
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

    private struct JoinControl: View {

                 fileprivate let items: [String];
        @Binding fileprivate var selected: String;
                 fileprivate let size: Int = Const.fontSize;
                 fileprivate let disabled: Bool;
                 fileprivate let leading: Int;
                 fileprivate let trailing: Int;
                 fileprivate let action: () async -> Void;

        private let horizontalPadding: CGFloat = 8;
        private let verticalPadding: CGFloat = 4;
        private let cornerRadius: CGFloat = 8;
        private let color: Color = .yellow;
        private let background: Color = Const.foreground;
        private let foregroundDisabled: Color = .gray;

        fileprivate init(items: [String], selected: Binding<String>, disabled: Bool = false,
                         leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil,
                         action: @escaping () async -> Void) {
            self.items = items;
            self._selected = selected;
            self.disabled = disabled;
            self.leading = leading ?? padding ?? 0;
            self.trailing = trailing ?? padding ?? 0;
            self.action = action;
        }

        fileprivate var body: some View {
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
                    Text(selected.isEmpty ? (items.first ?? Const.emptySetChar) : selected)
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

    private struct SmallButton: View {

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

        fileprivate init( _ text: String? = nil, icon: String? = nil,
                            color: Color? = nil, background: Color? = nil,
                            size: Int? = nil, disabled: Bool = false,
                            leading: Int? = nil, trailing: Int? = nil, padding: Int? = nil,
                            action: @escaping () async -> Void) {
            self.text = text;
            self.icon = icon;
            self.color = color ?? .yellow;
            self.background = background ?? Const.foreground;
            self.size = size ?? ((icon != nil) ? 20 : Const.fontSize);
            self.disabled = disabled;
            self.action = action;
            self.leading = leading ?? padding ?? 0;
            self.trailing = trailing ?? padding ?? 0;
        }

        fileprivate var body: some View {
            Button {
                Task { await action() }
            } label: {
                if let icon: String = icon {
                    Image(systemName: icon)
                        .foregroundColor(.black)
                        .font(.system(size: CGFloat(self.size)))
                        .fontWeight(.semibold)
                        .disabled(disabled)
                }
                else if let text: String = text {
                    Text(text)
                        .font(.system(size: CGFloat(self.size), weight: .semibold))
                        .foregroundColor(self.color)
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
            .padding(.leading, CGFloat(self.leading)).padding(.trailing, CGFloat(self.trailing))
        }
    }

    private struct RegularText: View {
        private let text: String;
        private let color: Color;
        private let size: Int;
        private var bold: Bool = false;
        private var semibold: Bool = false;
        private var strikeout: Bool = false;
        private let leading: Int;
        private let trailing: Int;
        fileprivate init(_ text: String, color: Color = .primary,
                           size: Int = Const.fontSize,
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
        fileprivate var body: some View {
            Text(self.text)
                .font(.system(size: CGFloat(self.size), weight: bold ? .bold : (semibold ? .semibold : .regular)))
                .foregroundColor(self.color)
                .padding(.leading, CGFloat(self.leading)).padding(.trailing, CGFloat(self.trailing))
                .strikethrough(self.strikeout)
        }
    }

    private struct CopyableText: View {

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

        fileprivate init(_ text: String, copy: String? = nil, color: Color = .primary,
                           size: Int = Const.fontSize,
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

        fileprivate var body: some View {
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
}
