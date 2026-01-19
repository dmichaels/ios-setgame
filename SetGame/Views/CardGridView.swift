import SwiftUI

public struct CardGridView: View {

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
        //   between each card (row) on the table card grid.
        //
        HStack(spacing: marginx) {
            let columns: Array<GridItem> = Array(
                repeating: GridItem(.flexible(), spacing: spacing),
                count: settings.cardsPerRow
            )
            Spacer()
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(table.cards, id: \.id) { card in
                    CardView(
                        card,
                        materialize: true,
                        askew: settings.cardsAskew,
                        alternate: settings.alternateCards
                    ) { card in
                        self.table.cardTouched(
                            card,
                            //
                            // The delay here is the amount of time to let the selected SET
                            // show as selected before we start blinking; the delayCallback
                            // is the amount of time to let the selecte SET show as selected
                            // AFTER the blinking is done before we replace with new cards.
                            //
                            delay: Defaults.Effects.selectDelay,
                            onSet: { cards, resolve in
                                cards.blink(delayCallback: Defaults.Effects.selectDelay) {
                                    resolve();
                                }
                            },
                            onNoSet: { cards, resolve in
                                cards.shake();
                                resolve();
                            },
                            onCardsMoved: { cards in
                                cards.flip(duration: 0.8);
                            }
                        )
                    }
                }
            }
            Spacer()
        }
    }
}
