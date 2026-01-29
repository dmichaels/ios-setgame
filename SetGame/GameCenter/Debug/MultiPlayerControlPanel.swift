import SwiftUI

private struct HttpServerInfo {
    public var isHost: Bool = false;
    public var players: [String] = [];
    public var playerCount: Int = 0;
    public var host: String = "";
    public var messageQueuedCount: Int = 0;
    public var messageQueuedTotalCount: Int = 0;
    public var messageSentCount: Int = 0;
    public var messageRetrievedCount: Int = 0;
    public var poll: Bool = true;
}

public struct MultiPlayerDevelopmentPanel: View {

    @ObservedObject var table: Table
    @ObservedObject var settings: Settings;

    @State fileprivate var info: HttpServerInfo = HttpServerInfo();
    @State private var taskHandle: Task<Void, Never>? = nil

    let transport: GameCenter.HttpTransport = GameCenter.HttpTransport.instance;

    public var body: some View {
        VStack {
            Space(size: 24)
            MultiPlayerControlPanel(table: table, settings: settings, info: $info)
            Space(size: 4)
            MultiPlayerInfoPanel(table: table, settings: settings, info: $info)
            Space(size: 4)
            MultiPlayerInfoPanelMessages(table: table, settings: settings, info: $info)
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
            self.taskHandle?.cancel();
            self.taskHandle = nil;
        }
    }

    private func pollingTaskStop() {
        self.taskHandle?.cancel();
        self.taskHandle = nil;
    }

    private func pollingTask() {
        guard self.settings.multiPlayer.enabled else { return }
        self.taskHandle = Task {
            while !Task.isCancelled {
                self.info.messageSentCount = transport.messageSentCount();
                self.info.messageRetrievedCount = transport.messageRetrievedCount();
                self.info.messageQueuedCount = await transport.retrieveMessageQueuedCount();
                self.info.messageQueuedTotalCount = await transport.retrieveMessageQueuedTotalCount();
                let players = await transport.retrievePlayers();
                self.info.playerCount = players.count;
                let host = await transport.retrieveHost();
                self.info.host = host;
                self.info.isHost = transport.player == host;
                print("WATCH> players: \(players) host: \(host)");
                try? await Task.sleep(nanoseconds: 300_000_000);
            }
        }
    }
}

public struct MultiPlayerControlPanel: View {
    @ObservedObject var table: Table
    @ObservedObject var settings: Settings;
    @Binding fileprivate var info: HttpServerInfo;
    let background: Color = Color.gray;
    let transport: GameCenter.HttpTransport = GameCenter.HttpTransport.instance;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                ToggleItem("multi", on: $settings.multiPlayer.enabled, disabled: false) { value in
                    if (!value) {
                        transport.stopMessagePolling();
                    }
                    else if (settings.multiPlayer.poll) {
                        transport.startMessagePolling();
                    }
                }
                ToggleItem("host", on: $info.isHost, disabled: !settings.multiPlayer.enabled) { value in
                    if (value) {
                        Task { await transport.setHost(); }
                    }
                    else {
                        Task { await transport.resetHost(); }
                    }
                }
                // ToggleItem("http", on: $settings.multiPlayer.http, disabled: !settings.multiPlayer.enabled)
                ToggleItem("poll", on: $settings.multiPlayer.poll, disabled: !settings.multiPlayer.enabled || !settings.multiPlayer.http) { value in
                    if (value) {
                        transport.startMessagePolling();
                    }
                    else {
                        transport.stopMessagePolling();
                    }
                }
                ToggleItem("watch", on: $info.poll, disabled: !settings.multiPlayer.enabled || !settings.multiPlayer.http)
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
    let background: Color = Color.gray;
    let transport: GameCenter.HttpTransport = GameCenter.HttpTransport.instance;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("id:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.trailing, -8)
                    .foregroundColor(self.info.isHost ? .red : .primary)
                    .underline(self.info.isHost)
                CopyableText(text: transport.player,
                             foreground: self.info.isHost ? .red : .primary,
                             background: self.background,
                             bold: self.info.isHost,
                             underline: self.info.isHost)
                Text("host:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(self.info.host != "" ? self.info.host : "∅")")
                    .font(.caption)
                    .padding(.trailing, 4)
                Text("players:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(self.info.playerCount)")
                    .font(.caption)
                Spacer()
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
}

public struct MultiPlayerInfoPanelMessages: View {
    @ObservedObject var table: Table
    @ObservedObject var settings: Settings;
    @Binding fileprivate var info: HttpServerInfo;
    @State private var taskHandle: Task<Void, Never>? = nil
    let background: Color = Color.gray;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("queued:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(self.info.messageQueuedCount)")
                    .font(.caption)
                    .padding(.trailing, 4)
                Text("total:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(self.info.messageQueuedTotalCount)")
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
                ResetMessagesButton()
                Spacer()
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
        let transport: GameCenter.HttpTransport = GameCenter.HttpTransport.instance;
        public var body: some View {
            Button {
                Task {
                    await transport.resetMessages();
                }
            } label: {
                Text("clear")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.leading, 8)
            }
        }
    }
}


private struct CopyableText: View {
    let text: String;
    let foreground: Color;
    let background: Color;
    let bold: Bool;
    let underline: Bool;
    @State private var copied = false;
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(bold ? .bold : .regular)
            .underline(underline)
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
