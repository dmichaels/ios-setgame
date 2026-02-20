import SwiftUI

public extension MultiPlayer.Dev {

    public struct ChatMessagesView: View {

        let player: String
        let messages: [MultiPlayer.ChatMessage]

        public var body: some View {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                            ChatBubbleView(player: player, message: message).id(index)
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
