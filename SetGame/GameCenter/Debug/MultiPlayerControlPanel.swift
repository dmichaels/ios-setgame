import SwiftUI

public struct MultiPlayerControlPanel: View {
    @ObservedObject var table: Table
    @ObservedObject var settings: Settings;
    let background: Color = Color.gray;
    let transport: GameCenter.HttpTransport = GameCenter.HttpTransport.instance;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                ToggleItem("multi", on: $settings.multiPlayer.enabled, disabled: false)
                ToggleItem("host", on: $settings.multiPlayer.host, disabled: !settings.multiPlayer.enabled)
                ToggleItem("http", on: $settings.multiPlayer.http, disabled: !settings.multiPlayer.enabled)
                ToggleItem("poll", on: $settings.multiPlayer.poll, disabled: !settings.multiPlayer.enabled || !settings.multiPlayer.http) { value in
                    print("Toggle polling changed to: \(value)")
                    if (value) { transport.startMessagePolling() } else { transport.stopMessagePolling() }
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
                .scaleEffect(0.55)
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
    @State private var taskHandle: Task<Void, Never>? = nil
    @State private var messageQueuedCount: Int = 0;
    @State private var messageSentCount: Int = 0;
    @State private var messageRetrievedCount: Int = 0;
    @State private var host: String = "";
    @State private var hosting: Bool = false;
    let background: Color = Color.gray;
    let transport: GameCenter.HttpTransport = GameCenter.HttpTransport.instance;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("id:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.trailing, -8)
                    .foregroundColor(self.hosting ? .red : .primary)
                    .underline(self.hosting)
                CopyableText(text: transport.player,
                             foreground: self.hosting ? .red : .primary,
                             background: self.background,
                             bold: self.hosting,
                             underline: self.hosting)
                if (!self.hosting) {
                    Text("host:")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("\(self.host)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                Text("queue:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(messageQueuedCount)")
                    .font(.caption)
                    .onAppear {
                        taskHandle = Task {
                            while !Task.isCancelled {
                                self.host = transport.host;
                                self.hosting = transport.hosting;
                                self.messageSentCount = transport.messageSentCount();
                                self.messageRetrievedCount = transport.messageRetrievedCount();
                                let count = await transport.retrieveMessageQueuedCount();
                                print("MC: \(count)");
                                await MainActor.run { messageQueuedCount = count };
                                try? await Task.sleep(nanoseconds: 300_000_000);
                                let players = await transport.retrievePlayers();
                                print("PLAYERS...........")
                                print(players)
                            }
                        }
                    }
                    .onDisappear {
                        taskHandle?.cancel();
                    }
                    .padding(.trailing, 4)
                Text("sent:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(messageSentCount)")
                    .font(.caption)
                    .padding(.trailing, 4)
                Text("retrieved:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(messageRetrievedCount)")
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
