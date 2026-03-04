import SwiftUI

public extension MultiPlayer.Dev {

    public struct ChatView: View {

        let player: String;
        @Binding public var players: [String];
        let messages: [MultiPlayer.ChatMessage];
        // let recipients: [String];
        @State var recipient: String = "todo";
        var transport: MultiPlayer.Transport;
        @ObservedObject var sessionState: SessionState;
        var background: Color = Color(.systemBackground);
        var backgroundInput: Color = Color(.systemBackground);
        var foreground: Color = .black;
        let onSend: (String, String) -> Void; // (text, recipient)

        var poller: Poller = Poller(milliseconds: 2000);

        @State private var inputText: String = ""

        public var body: some View {
            VStack(spacing: 0) {
                ChatRecipientView(players: $players, recipient: $recipient)
                ChatMessagesView(player: player, messages: messages)
                Divider()
                HStack {
                    TextField("Message…", text: $inputText)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(self.backgroundInput)
                        )
                        .foregroundColor(self.foreground)
                    Button {
                        send()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .disabled(self.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .background(self.background)
                .border(.red)
            }
            .onAppear {
                self.poller.start {
                    let x = await self.transport.chats(sender: "", recipient: "");
                    DEB("abc: \(self.players)")
                    DEB("def: \(self.sessionState.players)")
                }
            }
            .onDisappear {
                self.poller.stop();
            }
        }

        private func send() {
            let text: String = self.inputText.trimmingCharacters(in: .whitespacesAndNewlines);
            guard !text.isEmpty else { return }
            onSend(text, recipient);
            self.inputText = "";
        }
    }

    private struct ChatRecipientView: View {
        @Binding public var players: [String];
        @Binding public var recipient: String;
        public var body: some View {
            HStack(spacing: 0) {
                Image(systemName: "person")
                    .onTapGesture {
                        DEB("XXX: \(self.players)")
                    }
                Text("To: ").lineLimit(1).layoutPriority(1)
                Picker("", selection: $recipient) {
                    ForEach(self.players, id: \.self) { recipient in
                        Text(recipient)
                    }
                }.pickerStyle(.menu)
                Spacer()
            }
            .onAppear {
                DEB("ChatRecipientView.onAppear> \(self.players)")
            }
        }
    }
}
