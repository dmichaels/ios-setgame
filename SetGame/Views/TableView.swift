import SwiftUI

// This was previously TableView by factored out into this TableView module
// to eliminate references to global environment (@EnvironmentObject)
// state, in order to facilitate multi-player (GameCenter) functionality.
//
public struct TableView: View {

    @ObservedObject var table: Table;
    @ObservedObject var settings: Settings;
    @ObservedObject var feedback: Feedback;
 // @ObservedObject private var gameCenter = GameCenterManager.shared;

    let marginx: CGFloat = 6;
    let spacing: CGFloat = 6;

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CardGridView(table: table, settings: settings, spacing: spacing, marginx: marginx)
            Space(size: 18)
            StatusBar(marginx: marginx)
            Space(size: 12)
            FoundSets(table: table, settings: settings, marginx: marginx)
            MultiPlayerGameButton()
        }
        .allowsHitTesting(!self.table.state.disabled)
    }

    private struct StatusBar: View {
        var marginx: CGFloat = 8;
        var body: some View {
            HStack(spacing: marginx) {
                Spacer()
                StatusBarView()
                Spacer()
            }
        }
    }

    private struct FoundSets: View {
        @ObservedObject var table: Table;
        @ObservedObject var settings: Settings;
        var marginx: CGFloat = 8;
        var body: some View {
            if (self.settings.showFoundSets) {
                HStack(spacing: marginx) {
                    Spacer()
                    FoundSetsView(table: table, settings: settings)
                    Spacer()
                }
            }
        }
    }

    private struct MultiPlayerGameButton: View {
        var body: some View {
            if (false) {
                // PlayButtonView(gameCenter: gameCenter)
                //     .padding(.horizontal)
            }
        }
    }
}
