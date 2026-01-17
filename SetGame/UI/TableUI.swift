import SwiftUI

// This was previously TableView by factored out into this TableUI module
// to eliminate references to global environment (@EnvironmentObject)
// state, in order to facilitate multi-player (GameCenter) functionality.
//
public struct TableUI: View {

    @ObservedObject var table: Table;
    @ObservedObject var settings: Settings;
    @ObservedObject var feedback: Feedback;

    // @ObservedObject private var gameCenter = GameCenterManager.shared;

    private struct Defaults {
        fileprivate static let threeCardSelectDelay: Double = 0.75;
    }

    let marginx: CGFloat = 6;
    let spacing: CGFloat = 6;

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CardGrid(table: table, settings: settings, spacing: spacing, marginx: marginx)
            Space(size: 18)
            StatusBar(marginx: marginx)
            Space(size: 12)
            FoundSets(table: table, settings: settings, marginx: marginx)
            MultiPlayerGameButton()
        }
        .allowsHitTesting(!self.table.state.disabled)
    }

    private struct CardGrid: View  {

        @ObservedObject var table: Table;
        @ObservedObject var settings: Settings;

        var spacing: CGFloat = 8;
        var marginx: CGFloat = 8;

        public var body: some View {
            let spacingx: CGFloat = spacing;
            let spacingy: CGFloat = spacing;
            //
            // Spacing notes:
            // - marginx
            //   The HStack spacing is amount of horizontal space to
            //   the left and right of the table card grid itself;
            //   also requires Spacer before/after the LazyVGrid.
            // - spacingx
            //   The columns/GridItem array spacing is the horizontal
            //   space between each card on the table card grid.
            // - spacingy
            //   The LazyVGrid spacing is the vertical space
            //   between each card on the table card grid.
            //
            HStack(spacing: marginx) {
                let columns: Array<GridItem> = Array(
                    repeating: GridItem(.flexible(), spacing: spacing),
                    count: settings.cardsPerRow
                )
                Spacer()
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(table.cards, id: \.id) { card in
                        CardUI(
                            card,
                            materialize: true, // table.state.newcomers.contains(card.id),
                            askew: settings.cardsAskew,
                            alternate: settings.alternateCards
                        ) { card in
                            self.table.cardTouched(card, delay: Defaults.threeCardSelectDelay) { cards, set, resolve in
                                if let set: Bool = set {
                                    if (set) {
                                        cards.blink() {
                                            resolve();
                                        }
                                    }
                                    else {
                                        cards.shake();
                                        resolve();
                                    }
                                }
                                else {
                                    resolve();
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
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
