import SwiftUI

public extension MultiPlayer.Dev {

    public struct ChatBubbleView: View {

        let message: MultiPlayer.ChatMessage
        let currentPlayer: String

        private var isMe: Bool {
            message.from == currentPlayer
        }

        public var body: some View {
            HStack {
                if isMe { Spacer() }

                Text(message.text)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isMe ? Color.blue : Color.gray.opacity(0.25))
                    )
                    .foregroundColor(isMe ? .white : .primary)
                    .frame(maxWidth: 260, alignment: isMe ? .trailing : .leading)

                if !isMe { Spacer() }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
        }
    }
}
