import SwiftUI

public struct MultiPlayerControlPanel: View {
    @ObservedObject var table: Table
    @ObservedObject var settings: Settings;
    let background: Color = Color.gray;
    let transport: GameCenter.HttpTransport = GameCenter.HttpTransport.instance;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                ToggleItem("multiplayer:", on: $settings.multiPlayer.enabled, disabled: false)
                ToggleItem("host:", on: $settings.multiPlayer.host, disabled: !settings.multiPlayer.enabled)
                ToggleItem("http:", on: $settings.multiPlayer.http, disabled: !settings.multiPlayer.enabled)
                ToggleItem("polling:", on: $settings.multiPlayer.poll, disabled: !settings.multiPlayer.enabled || !settings.multiPlayer.http) { value in
                    print("Toggle polling changed to: \(value)")
                    if (value) { transport.startMessagePolling() } else { transport.stopMessagePolling() }
                }
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.vertical, 2)
            .frame(width: 410)
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
    @State private var messageCount: Int = 0;
    let background: Color = Color.gray;
    let transport: GameCenter.HttpTransport = GameCenter.HttpTransport.instance;
    public var body: some View {
        VStack(spacing: 80) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("player:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.trailing, -8)
                CopyableText(text: transport.player, background: self.background)
                Spacer()
                Text("messages:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.trailing, -8)
                Text("\(messageCount)")
                    .font(.caption)
                    .padding(.trailing, -8)
                    .task { messageCount = await transport.retrieveMessageCount() }
                    .onAppear {
                        taskHandle = Task {
                            while !Task.isCancelled {
                                let count = await transport.retrieveMessageCount()
                                print("MC: \(count)")
                                await MainActor.run { messageCount = count }
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                            }
                        }
                    }
            .onDisappear {
                taskHandle?.cancel()
            }
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.vertical, 2)
            .frame(width: 410)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(self.background.opacity(0.2))
            )
        }
    }
}

private struct CopyableText: View {
    let text: String;
    let background: Color;
    @State private var copied = false;
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(8)
            .cornerRadius(8)
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
    }
}
