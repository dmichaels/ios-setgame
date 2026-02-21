import SwiftUI

public extension MultiPlayer.Dev {

    public struct DevPanelView: View {

        @ObservedObject private var table: Table
        @ObservedObject private var settings: Settings;
                        private var margin: Int = 10;

                 @State private var sessionState: SessionState;
                        private let pollInterval: Int = 500;

        private var session: MultiPlayer.Session { MultiPlayer.HttpSession.instance }
        private var transport: MultiPlayer.Transport { MultiPlayer.HttpSession.instance.transport as! MultiPlayer.HttpTransport }

        // var chats: [MultiPlayer.ChatMessage] = [];

        public init(table: Table, settings: Settings, margin: Int = 0) {
            LOGD("DevPanelView.init!!!")
            self.table = table;
            self.settings = settings;
            self.margin = margin;
            self.sessionState = SessionState(player: MultiPlayer.HttpSession.instance.player,
                                             pollInterval: pollInterval);
            /*
            self.chats.append(contentsOf: [
                MultiPlayer.ChatMessage("Hello, world!"),
                MultiPlayer.ChatMessage("EOF")
            ]);
            */
        }

        public var body: some View {
            VStack {
                DevPanelInfo(table: table, session: session, transport: transport, sessionState: $sessionState, margin: margin)
                DevPanelSession(table: table, session: session, transport: transport, sessionState: $sessionState, margin: 12)
                DevPanelPlayers(table: table, session: session, transport: transport, sessionState: $sessionState, margin: 12)
                DevPanelMessages(table: table, session: session, transport: transport, sessionState: $sessionState, margin: 12)
                DevPanelServer(table: table, session: session, transport: transport, sessionState: $sessionState, margin: 12)
                // ChatMessagesView(player: self.session.player, messages: self.chats)
                ChatView(player: self.session.player,
                         messages: self.sessionState.chats,
                         recipient: "TODO",
                         background: Defaults.background,
                         backgroundInput: Defaults.background) { text, recipient in
                    LOGD("ChatView.callback> text: [\(text)] recipient: [\(recipient)]")
                }
            }
            .onAppear { self.sessionState.poll({
                self.sessionState.update(from: self.session,
                                         info: await self.transport.session(self.session.session),
                                         sessions: await self.transport.sessions(),
                                         pingable: await self.transport.ping(),
                                         production: transport.production,
                                         server: transport.server,
                                         debug: await transport.debug(enable: nil),
                                         chats: await self.retrieveChats());
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

        private func retrieveChats() async -> [MultiPlayer.ChatMessage] {
            if let recipient: String = self.sessionState.players.first { $0 != self.sessionState.player } {
                if let chats = await self.transport.chats(sender: self.sessionState.player, recipient: recipient) {
                    DEB("retrieved-chats")
                    print(chats)
                    return chats;
                }
            }
            return [];
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
                 // CopyableText(sessionState.player,
                 //              color: self.session.hosting ? Defaults.highlightColor : .primary, semibold: true, leading: 3)
                    CopyableText(sessionState.player + (sessionState.player == sessionState.host ? " \(Defaults.starChar)" : ""), semibold: true, leading: 3)
                if (sessionState.player != sessionState.host) {
                    RegularText("host:", leading: 10)
                        CopyableText("\(self.sessionState.host ?? Defaults.emptySetChar)",
                                     color: self.session.hosting ? Defaults.highlightColor : .primary,
                                     semibold: true, leading: 3)
                }
                RegularText("players:", leading: 10)
                    RegularText("\(self.sessionState.players.count == 0 ? Defaults.emptySetChar : "\(self.sessionState.players.count)")", leading: 3)
                Spacer()
                SmallButton(icon: self.transport.engaged ? "pause.circle" : "play.circle", disabled: !self.sessionState.connected) {
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
                            }
                            else {
                                //
                                // TODO: Do something if join-session fails?
                                //
                                let x = 1;
                                DEB("join-failed: \(sessionState.sessions.selected)")
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
                            DEB("host-failed")
                        }
                    }
                }
                RegularText("", padding: 2)
                SmallButton(icon: "xmark.rectangle.portrait", size: Defaults.iconSize + 4, disabled: !self.sessionState.leaveable) {
                    if let info = await self.transport.session(self.session.session) {
                        let (sent, queued, received) = MultiPlayer.HttpTransport.messageCounts(info: info, player: self.session.player);
                    }
                    if (self.session.connected) {
                        if await self.session.leave() {
                            self.sessionState.update(from: self.session);
                        }
                        else {
                            //
                            // TODO: Do something if leave-session fails?
                            //
                            DEB("leave-failed")
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
                PlayersView(session: self.session,
                            sessionState: self.sessionState,
                            players: self.sessionState.players,
                            player: self.sessionState.player,
                            host: self.sessionState.host ?? "",
                            info: self.sessionState.info)
            }
        }

        private struct PlayersView: View {

            private let session: MultiPlayer.Session;
            private let sessionState: SessionState;
            private let players: [String];
            private let player: String;
            private let host: String;
            private let noplayers: Bool;
            private var sent: [String: Int] = [:];
            private var received: [String: Int] = [:];
            private var queued: [String: Int] = [:];
            private let size: Int;

            fileprivate init(session: MultiPlayer.Session, sessionState: SessionState,
                             players: [String], player: String,
                             host: String, info: Json, size: Int = Defaults.fontSize) {
                self.session = session;
                self.sessionState = sessionState;
                self.noplayers = (players.count == 0);
                self.player = player;
                self.players = (players.count == 0) ? [player] : players;
                self.host = host;
                for player in players {
                    let (sent, queued, received) = MultiPlayer.HttpTransport.messageCounts(info: info, player: player)
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
                            HStack {
                                Text(player + (player == self.player ? " ◀" : ""))
                                    .foregroundColor(player == self.host ? Defaults.highlightColor : Color.primary)
                                SmallButton(icon: "dot.scope", bold: true, disabled: !self.sessionState.connected) {
                                    LOGD("sending ping to: \(player)")
                                    let xxx = await self.session.ping(player: player, timeout: 5000);
                                    LOGD("back from await for sending ping to: \(player)")
                                    LOGD(xxx ? "ping result true" : "ping result false")
                                }
                                SmallButton(icon: "ellipsis.message", disabled: !self.sessionState.connected) {
                                    LOGD("sending text to: \(player)")
                                    if let recipient: String = self.sessionState.players.first { $0 != self.sessionState.player } {
                                        let message: MultiPlayer.ChatMessage = MultiPlayer.ChatMessage(
                                            "Hello, world! FROM [\(self.sessionState.player)] to [\(recipient)]");
                                        let xxx = await self.session.send(message: message, to: recipient);
                                        LOGD("back from await for text send to: \(player)")
                                        LOGD(xxx ? "text send result true" : "text send result false")
                                    }
                                }
                                Spacer()
                            }
                            Text(self.noplayers ? Defaults.emptySetChar : "\(sent[player] ?? 0)")
                                .frame(width: 40, alignment: .trailing)
                            Text(self.noplayers ? Defaults.emptySetChar : "\(received[player] ?? 0)")
                                .frame(width: 70, alignment: .trailing)

                            Text(self.noplayers ? Defaults.emptySetChar : "\(queued[player] ?? 0)")
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(.vertical, 2)
                        if index < players.count - 1 {
                            Rectangle()
                                .fill(Color.black)
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

            @Binding fileprivate var sessionState: SessionState;
                         private let size: Int = Defaults.fontSize;

            @State private var verbose: Bool = false;
            @State private var verboseSave: Bool = false;
            @State private var byTimestamp: Bool = false;
            @State private var byTimestampReversed: Bool = false;

            private static let includeHostColumn: Bool = false;

            fileprivate init(sessionState: Binding<SessionState>) {
                self._sessionState = sessionState;
            }

            private var player: String {
                return sessionState.player;
            }

            // private var host: String {
                // return sessionState.host ?? "";
            // }

            private var players: [String] {
                func reorderFirst(_ list: [String], first: String) -> [String] {
                    guard list.contains(first) else { return list };
                    return [first] + list.filter { $0 != first };
                }
                return reorderFirst(sessionState.players, first: self.player);
            }

            private var messages: [String: [MultiPlayer.HttpTransport.MessageReceived]] {
                var result: [String: [MultiPlayer.HttpTransport.MessageReceived]] = [:]
                if (verbose) {
                    for player in sessionState.players {
                        if let received = MultiPlayer.HttpTransport.messagesReceived(info: sessionState.info, player: player) {
                            result[player] = received;
                        }
                    }
                }
                else {
                    if let received = MultiPlayer.HttpTransport.messagesReceived(info: sessionState.info, player: sessionState.player) {
                        result[sessionState.player] = received;
                    }
                }
                return result;
            }

            private var messagesByTimestamp: [MultiPlayer.HttpTransport.MessageReceived] {
                if let messages = MultiPlayer.HttpTransport.messagesReceivedByTimestamp(info: sessionState.info, reversed: self.byTimestampReversed) {
                    return messages;
                }
                return [];
            }

            private static func messageType(_ message: MultiPlayer.Message) -> String {
                switch message.type {
                    case .ping:                 return "ping";
                    case .pingAcknowledge:      return "ping-ack";
                    case .joinSession:          return "join";
                    case .joinSessionConfirmed: return "joined";
                    case .leaveSession:         return "leave";
                    case .requestHostSession:   return "host";
                    case .updateSession:        return "update";
                    case .newGame:              return "new-game";
                    case .setFound:             return "set-found";
                    case .setConfirmed:         return "set-confirm";
                    case .setMissed:            return "set-missed";
                    case .chat:                 return "chat";
                }
            }

            private static let columns: [GridItem] = MessagesView.includeHostColumn ?
            [
                GridItem(.fixed(90), alignment: .leading),  // to
                GridItem(.fixed(70), alignment: .leading),  // from
                GridItem(.flexible(), alignment: .leading), // received
                GridItem(.fixed(70), alignment: .leading),  // host
                GridItem(.fixed(95), alignment: .leading)   // time
            ] :
            [
                GridItem(.fixed(90), alignment: .leading),  // to
                GridItem(.fixed(70), alignment: .leading),  // from
                GridItem(.flexible(), alignment: .leading), // received
                GridItem(.fixed(95), alignment: .leading)   // time
            ];

            private func expandButtonDownArrow() -> Bool {
                if (self.byTimestamp) {
                    return !self.byTimestampReversed;
                }
                else {
                    return self.verbose;
                }
            }

            fileprivate var body: some View {
                VStack(spacing: 4) {
                    LazyVGrid(columns: MessagesView.columns, alignment: .leading, spacing: 4) {
                        Text("to").bold()
                        Text("from").bold()
                        Text("type").bold()
                        if (MessagesView.includeHostColumn) {
                            Text("host").bold()
                        }
                        HStack {
                            Text("time").bold()
                            Spacer()
                            SmallButton(icon: self.expandButtonDownArrow() ? "arrow.down.square" : "arrow.up.square" , size: Defaults.iconSize) {
                                if (self.byTimestamp) {
                                    self.byTimestampReversed.toggle();
                                }
                                else {
                                    self.verbose.toggle();
                                }
                            }
                            SmallButton(icon: verbose ? "clock" : "clock",
                                        color: self.byTimestamp ? Defaults.highlightColor : Defaults.iconColor,
                                        size: Defaults.iconSize) {
                                if (self.byTimestamp) {
                                    self.byTimestamp = false;
                                    self.verbose = self.verboseSave;
                                }
                                else {
                                    self.byTimestamp = true;
                                    self.verboseSave = self.verbose;
                                }
                            }
                        }
                    }
                    Rectangle().fill(Color.black).frame(height: 2 / UIScreen.main.scale)
                    if (self.byTimestamp) {
                        ForEach(self.messagesByTimestamp) { message in
                            LazyVGrid(columns: MessagesView.columns, alignment: .leading, spacing: 4) {
                                Text(message.to + (message.to == message.host ? " \(Defaults.starChar)" : ""))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(message.to == self.player ? Defaults.highlightColor : .primary)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                                Text("\(message.message.sender + (message.message.sender == message.host ? " \(Defaults.starChar)" : ""))")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(message.message.sender == self.player ? Defaults.highlightColor : .primary)
                                    .lineLimit(1)
                                Text("\(MessagesView.messageType(message.message))")
                                    .font(.system(size: 13, weight: .regular))
                                    .lineLimit(1)
                                if (MessagesView.includeHostColumn) {
                                    Text("\(message.host)")
                                        .font(.system(size: 13, weight: .regular))
                                }
                                Text("\(message.timestamp)")
                                    .font(.system(size: 13, weight: .regular))
                            }
                        }
                    }
                    else {
                        ForEach(self.players, id: \.self) { player in
                            if let received: [MultiPlayer.HttpTransport.MessageReceived] = self.messages[player] {
                                LazyVGrid(columns: MessagesView.columns, alignment: .leading, spacing: 4) {
                                    Text(player + (player == self.sessionState.host ? " \(Defaults.starChar)" : ""))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(player == self.player ? Defaults.highlightColor : .primary)
                                        .frame(maxHeight: .infinity, alignment: .topLeading)
                                    VStack(alignment: .leading, spacing: 2) {
                                        ForEach(received, id: \.id) { message in
                                            Text("\(message.message.sender + (message.message.sender == message.host ? " \(Defaults.starChar)" : ""))")
                                                .font(.system(size: 13, weight: .regular))
                                                .foregroundColor(message.message.sender == self.player ? Defaults.highlightColor : .primary)
                                                .lineLimit(1)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        ForEach(received, id: \.id) { message in
                                            Text("\(MessagesView.messageType(message.message))")
                                                .font(.system(size: 13, weight: .regular))
                                                .lineLimit(1)
                                        }
                                    }
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                                    if (MessagesView.includeHostColumn) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            ForEach(received, id: \.id) { message in
                                                Text("\(message.host)")
                                                    .font(.system(size: 13, weight: .regular))
                                            }
                                        }
                                        .frame(maxHeight: .infinity, alignment: .topLeading)
                                    }
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

        private var pollCountChar: String {
            let m: Int = self.sessionState.pollCount % 6;
            if      (m == 0) { return "―";  }
            else if (m == 1) { return "\\"; }
            else if (m == 2) { return "|"; }
            else if (m == 3) { return "/"; }
            else if (m == 4) { return "o"; }
            else if (m == 5) { return "+"; }
            else             { return "x"; }
        }

        fileprivate var body: some View {
            AnyDevPanel(table: table, vertical: 2, margin: margin) {
                HStack {
                    RegularText("server: ", size: 13)
                        RegularText(self.sessionState.server,
                                    color: self.sessionState.pingable ? .primary : Defaults.highlightColor,
                                    size: 12, bold: true, leading: -4)
                            RegularText(self.sessionState.pingable ? Defaults.checkChar : Defaults.xmarkChar,
                                        color: self.sessionState.pingable ? .primary : Defaults.highlightColor,
                                        size: 12, semibold: true, leading: 2)
                    Spacer()
                    HStack {
                        if (self.sessionState.polling) {
                            PollSpinner(count: self.sessionState.pollCount, size: Defaults.iconSize)
                        }
                        else {
                            Image(systemName: "play.circle")
                                .font(.system(size: CGFloat(Defaults.iconSize)))
                                .foregroundColor(Defaults.iconColor)
                        }
                    }
                    .onTapGesture { self.sessionState.poll(enable: !self.sessionState.polling); }
                    SmallButton(icon: self.sessionState.production ? "checkmark.seal" : "atom", size: Defaults.iconSize) {
                        await self.transport.production = !self.sessionState.production;
                    }
                    SmallButton(icon: self.sessionState.debug ? "ladybug" : "ladybug.slash", size: Defaults.iconSize) {
                        await self.transport.debug(enable: !self.sessionState.debug);
                    }
                }
            }
        }
    }
}
