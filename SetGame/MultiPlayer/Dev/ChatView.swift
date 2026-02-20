import SwiftUI

public extension MultiPlayer.Dev {

public struct ChatView: View {

    let player: String
    let messages: [MultiPlayer.ChatMessage]
    let recipient: String
    var background: Color = Color(.systemBackground)
    var backgroundInput: Color = Color(.systemBackground)
    var foreground: Color = .black;
    let onSend: (String, String) -> Void   // (text, recipient)

    @State private var inputText: String = ""

    public var body: some View {
        VStack(spacing: 0) {

            ChatMessagesView(
                player: player,
                messages: messages
            )

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
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(self.background)
            .border(.red)
        }
    }

    private func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        onSend(trimmed, recipient)

        inputText = ""
    }
}
}
