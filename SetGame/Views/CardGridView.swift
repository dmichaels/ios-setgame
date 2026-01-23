import SwiftUI

public struct CardGridView: View {

    @ObservedObject var table: Table;
    @ObservedObject var settings: Settings;
    var materialize: Bool = true;
    var materializeDelay: Double = 0;

    var spacing: CGFloat = 6;
    var marginx: CGFloat = 6;

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
        //   between each card (row) on the table card grid.
        //
        HStack(spacing: marginx) {
            let columns: Array<GridItem> = Array(
                repeating: GridItem(.flexible(), spacing: spacing),
                count: settings.cardsPerRow
            )
            Spacer()
            LazyVGrid(columns: columns, spacing: spacing) {
                //
                // Change the id on the ForEach from \.id to \.uid (2026-01-20)
                // to fix issue with (for example) TableCard.materializeTrigger
                // getting called on an item that was removed and then incorrectly
                // materializing (fading in) the card if the card was previously
                // in the table.cards list; for example when doing add-card after
                // new-game where the card added was in a previous game.
                //
                // The materializeDelay argument to CardView is the amount of
                // time (seconds) to wait until the materialization (fading in)
                // of the card begins; we use a smalle random amount of time
                // here so the cards come into being in a staggered, visually
                // interesting, fashion.
                //
                ForEach(table.cards, id: \.uid) { card in
                    CardView(
                        card,
                        // materialize: materialize,
                        materialize: materialize ? .materialize : .none,
                        materializeDelay: materializeDelay > 0 ?
                                          materializeDelay : Defaults.Effects.materializeRandomDelay,
                        askew: settings.cardsAskew,
                        alternate: settings.alternateCards
                    ) { card in
                        CardGridCallbacks.cardTouched(card, table: self.table);
                    }
                }
            }
            Spacer()
        }
    }
}
