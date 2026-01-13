import GameKit
import SwiftUI

struct PlayButtonView: View {
    @ObservedObject var gameCenter: GameCenterManager

    var body: some View {
        Button {
            if (!GKLocalPlayer.local.isAuthenticated) {
                print("BUTTON-NOT-AUTH")
                // gameCenter.openGameCenterSettings()
                gameCenter.showSettingsAlert = true
            }
            else {
                gameCenter.playWithFriends(minPlayers: 2, maxPlayers: 4)
            }
        } label: {
            Text("Play with Friends")
                .lineLimit(1)
        }
        .buttonStyle(.borderedProminent)
        // .disabled(!GKLocalPlayer.local.isAuthenticated)
        /* xyzzy
        .alert("Game Center Required",
               isPresented: $gameCenter.showSettingsAlert) {
            Button("Open Settings") { gameCenter.openGameCenterSettings() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(gameCenter.settingsAlertMessage)
        }
        */
    }
}
