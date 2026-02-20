import SwiftUI

public extension MultiPlayer.Dev {

    public struct ChatView: View {

        let messages: [MultiPlayer.ChatMessage]
        let currentPlayer: String

        public var body: some View {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                            ChatBubbleView(
                                message: message,
                                currentPlayer: currentPlayer
                            )
                            .id(index)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: messages.count) { _ in
                    if let lastIndex = messages.indices.last {
                        withAnimation {
                            proxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}
