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
                        CardGridView.cardTouchedDefault(card, table: self.table);
                    }
                }
            }
            Spacer()
        }
    }

    public static func cardTouchedDefault(_ card: TableCard, table: Table) {
        table.cardTouched(
            card,
            //
            // The delay argument to cardTouched is the amount of time (seconds)
            // to let the selected SET show as selected BEFORE we start blinking;
            // the delay within the blink callback is the amount of time to let
            // the selected SET show as selected AFTER the blinking is done and
            // BEFORE we replace them with new cards (via resolve).
            //
            delay: Defaults.Effects.selectBeforeSetDelay,
            onSet: { cards, resolve in
                cards.blink {
                    Delay(by: Defaults.Effects.selectAfterSetDelay) {
                        resolve();
                    }
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
