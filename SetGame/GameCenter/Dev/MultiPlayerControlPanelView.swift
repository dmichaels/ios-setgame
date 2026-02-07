import SwiftUI

private struct HttpServerInfo {
    public var isHost: Bool = false;
    public var sessionHosting: Bool = false;
    public var sessionHost: String = "";
    public var sessionPlayers: [String] = [];
    public var sessionPlayerCount: Int = 0;
    public var players: [String] = [];
    public var playerCount: Int = 0;
    public var playerRegistered: Bool = false;
    public var host: String = "";
    public var messageQueueLength: Int = 0;
    public var messageQueueLengthAll: Int = 0;
    public var messageSentCount: Int = 0;
    public var messageRetrievedCount: Int = 0;
    public var messageHandledCount: Int = 0;
    public var poll: Bool = true;
}

public struct MultiPlayerDevelopmentPanelView: View {

    @ObservedObject var table: Table
    @ObservedObject var settings: Settings;

    @State private var info: HttpServerInfo = HttpServerInfo();
    @State private var taskHandle: Task<Void, Never>? = nil

    private var session: GameCenter.HttpSession? {
        return GameCenter.HttpSession.instance;
    }

    private var transport: GameCenter.HttpTransport? {
        return self.session?.transport as? GameCenter.HttpTransport
    }

    public init(table: Table, settings: Settings) {
        self.table = table;
        self.settings = settings;
    }

    public var body: some View {
        VStack {
            Space(size: 24)
            MultiPlayerControlPanel(table: table, settings: settings, info: $info, session: self.session, transport: self.transport)
            Space(size: 4)
            MultiPlayerInfoPanel(table: table, settings: settings, info: $info, session: self.session, transport: self.transport)
            Space(size: 4)
            MultiPlayerInfoPanelMessages(table: table, settings: settings, info: $info, transport: self.transport)
        }
        .onAppear {
            if (self.info.poll) {
                self.pollingTask();
            }
        }
        .onChange(of: self.info.poll) { value in
            self.pollingTaskStop();
            if (value) { self.pollingTask() }
        }
        .onDisappear {
            self.pollingTaskStop();
        }
    }

    private func pollingTaskStop() {
        self.taskHandle?.cancel();
        self.taskHandle = nil;
    }

    private func pollingTask() {
        guard self.info.poll else { return }
        self.taskHandle = Task {
            while !Task.isCancelled {
                if let transport = self.transport {
                    self.info.messageSentCount = transport.info.counts.sent;
                    self.info.messageRetrievedCount = transport.info.counts.retrieved;
                    self.info.messageHandledCount = transport.info.counts.handled;
                    self.info.messageQueueLength = transport.info.counts.queued;
                    self.info.messageQueueLengthAll = transport.info.counts.queuedTotal;
                    let players = await transport.retrievePlayers();
                    self.info.playerCount = players.count;
                    self.info.playerRegistered = players.contains(transport.player);
                    let host = await transport.retrieveHost();
                    self.info.host = host;
                    self.info.isHost = transport.player == host;
                }
                if let session = self.session {
                    session.updatePlayers();
                    self.info.sessionPlayers = session.players;
                    self.info.sessionPlayerCount = session.players.count;
                    self.info.sessionHost = session.host ?? "";
                    self.info.sessionHosting = session.hosting ?? false;
                }
                try? await Task.sleep(nanoseconds: 300_000_000);
            }
        }
    }
}

public struct MultiPlayerControlPanel: View {
    @ObservedObject var table: Table
    @ObservedObject var settings: Settings;
    @Binding fileprivate var info: HttpServerInfo;
    let session: GameCenter.HttpSession?;
    let transport: GameCenter.HttpTransport?;
    let background: Color = Color.gray;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                ToggleItem("multi", on: $settings.multiPlayer.enabled, disabled: false) { value in
                    if (!value) {
                        self.transport?.release();
                    }
                    else if (settings.multiPlayer.poll) {
                        self.transport?.setup();
                    }
                }
                ToggleItem("host", on: $info.isHost /*, disabled: !settings.multiPlayer.enabled */ ) { value in
                    if (value) {
                        Task {
                            await self.transport?.setHost();
                            session?.updatePlayers();
                        }
                    }
                    else {
                        Task {
                            await self.transport?.unsetHost();
                            session?.updatePlayers();
                        }
                    }
                }
                ToggleItem("poll", on: $settings.multiPlayer.poll /* , disabled: !settings.multiPlayer.enabled */ ) { value in
                    if (value) {
                        self.transport?.setup();
                    }
                    else {
                        self.transport?.release();
                    }
                }
                Spacer()
            }
            .padding(.leading, 11)
            .padding(.vertical, 2)
            .frame(width: 380)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(self.background.opacity(0.2))
            )
        }
    }
    private func ToggleItem(_ label: String, on: Binding<Bool>, disabled: Bool = false, callback: ((Bool) -> Void)? = nil) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(1)
                .layoutPriority(1)
                .padding(.trailing, -8)
            Toggle("", isOn: on)
                .labelsHidden()
                .scaleEffect(0.50)
                .disabled(disabled)
                .onChange(of: on.wrappedValue) { value in
                    callback?(value)
                }
        }
    }
}

public struct MultiPlayerInfoPanel: View {
    @ObservedObject var table: Table
    @ObservedObject var settings: Settings;
    @Binding fileprivate var info: HttpServerInfo;
    let session: GameCenter.HttpSession?;
    let transport: GameCenter.HttpTransport?;
    let background: Color = Color.gray;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("id:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.trailing, -8)
                    .foregroundColor(self.info.isHost ? .red : .primary)
                    .underline(self.info.isHost)
                CopyableText(text: transport?.player ?? "",
                             foreground: self.info.isHost ? .red : .primary,
                             background: self.background,
                             bold: self.info.isHost,
                             underline: self.info.isHost,
                             strikeout: !self.info.playerRegistered)
                if (self.info.playerRegistered) {
                    Text("✓")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.leading, -5)
                        .padding(.trailing, 2)
                        .offset(y: -1)
                }
                Text("host:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(!self.info.host.isEmpty ? self.info.host : "∅")")
                    .font(.caption)
                    .padding(.trailing, 4)
                    .foregroundColor((self.info.sessionHost != self.info.host) || (self.info.sessionHosting != self.info.isHost) ? .blue : .primary)
                Text("players:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(self.info.playerCount)")
                    .font(.caption)
                    .foregroundColor(self.info.playerCount != self.info.sessionPlayerCount ? .red : .primary)
                Spacer()
                PingButton(session: self.session, transport: self.transport)
                PingAllButton(session: self.session, transport: self.transport)
                RegisterPlayerButton(session: self.session, transport: self.transport)
                ResetServerButton(session: self.session, transport: self.transport, table: self.table)
            }
            .padding(.leading, 10)
            .padding(.vertical, 2)
            .frame(width: 380)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(self.background.opacity(0.2))
            )
        }
    }

    private struct PingButton: View {
        let session: GameCenter.HttpSession?;
        let transport: GameCenter.HttpTransport?;
        public var body: some View {
            Button {
                Task {
                    await session?.send(message: GameCenter.PingMessage());
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            .padding(.trailing, 10)
        }
    }

    private struct PingAllButton: View {
        let session: GameCenter.HttpSession?;
        let transport: GameCenter.HttpTransport?;
        public var body: some View {
            Button {
                Task {
                    if let session = self.session {
                        for player in session.players {
                            await session.send(message: GameCenter.PingMessage(), to: player);
                        }
                    }
                }
            } label: {
                Image(systemName: "paperplane.circle")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            .padding(.trailing, 10)
        }
    }

    private struct RegisterPlayerButton: View {
        let session: GameCenter.HttpSession?;
        let transport: GameCenter.HttpTransport?;
        public var body: some View {
            Button {
                Task {
                    await self.session?.register();
                }
            } label: {
                Image(systemName: "person.fill.checkmark")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            .padding(.trailing, 10)
        }
    }

    private struct ResetServerButton: View {
        let session: GameCenter.HttpSession?;
        let transport: GameCenter.HttpTransport?;
        let table: Table
        public var body: some View {
            Button {
                Task {
                    await self.transport?.reset();
                    await self.session?.updatePlayers();
                    self.table.state.resolving = false;
                }
            } label: {
                Image(systemName: "arrow.clockwise.circle")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            .padding(.trailing, 10)
        }
    }
}

public struct MultiPlayerInfoPanelMessages: View {
    @ObservedObject var table: Table
    @ObservedObject var settings: Settings;
    @Binding fileprivate var info: HttpServerInfo;
    let transport: GameCenter.HttpTransport?;
    @State private var taskHandle: Task<Void, Never>? = nil
    let background: Color = Color.gray;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("queued:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(self.info.messageQueueLength)")
                    .font(.caption)
                    .padding(.trailing, 4)
                Text("total:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(self.info.messageQueueLengthAll)")
                    .font(.caption)
                    .padding(.trailing, 4)
                Text("sent:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(self.info.messageSentCount)")
                    .font(.caption)
                    .padding(.trailing, 4)
                Text("retrieved:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(self.info.messageRetrievedCount)")
                    .font(.caption)
                    .foregroundColor(self.info.messageRetrievedCount != self.info.messageHandledCount ? .red : .primary)
                    .bold(self.info.messageRetrievedCount != self.info.messageHandledCount)
                Spacer()
                ResetMessagesButton(transport: self.transport, table: self.table)
                ResetMessagesAllButton(transport: self.transport, table: self.table)
            }
            .padding(.leading, 10)
            .padding(.vertical, 10)
            .frame(width: 380)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(self.background.opacity(0.2))
            )
        }
    }

    private struct ResetMessagesButton: View {
        let transport: GameCenter.HttpTransport?;
        let table: Table;
        public var body: some View {
            Button {
                Task {
                    await self.transport?.resetMessages();
                    self.table.state.resolving = false;
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            .padding(.trailing, 10)
        }
    }

    private struct ResetMessagesAllButton: View {
        let transport: GameCenter.HttpTransport?;
        let table: Table;
        public var body: some View {
            Button {
                Task {
                    await self.transport?.resetMessages(all: true);
                    self.table.state.resolving = false;
                }
            } label: {
                Image(systemName: "arrow.clockwise.circle")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            .padding(.trailing, 10)
        }
    }
}


private struct CopyableText: View {
    let text: String;
    let foreground: Color;
    let background: Color;
    let bold: Bool;
    let underline: Bool;
    let strikeout: Bool;
    @State private var copied = false;
    var body: some View {
        Text(text)
            .font(.caption)
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
                copied ? Text("Copied!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(6)
                    .offset(y: -40)
                    .transition(.opacity)
                : nil
            )
            .padding(.trailing, -4)
    }
}
