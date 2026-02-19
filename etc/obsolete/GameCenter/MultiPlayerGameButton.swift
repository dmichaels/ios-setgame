import SwiftUI

public struct MultiPlayerGameButton: View {
    @ObservedObject private var gameCenter = GameCenterManager.shared;
    public var body: some View {
        if (true) {
            PlayButtonView(gameCenter: gameCenter)
                .padding(.horizontal)
        }
    }
}
