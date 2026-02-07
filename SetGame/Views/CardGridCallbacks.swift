import SwiftUI

enum CardGridCallbacks
{
    public static func cardTouched(_ card: TableCard, table: Table) {
        table.cardTouched(
            card,
            //
            // The delay argument to cardTouched is the amount of time (seconds)
            // to let the selected SET show as selected BEFORE we start blinking;
            // the delay within the blink callback is the amount of time to let
            // the selected SET show as selected AFTER the blinking is done and
            // BEFORE we replace them with new cards (via resolve).
            //
            delay: Defaults.Effects.selectBeforeDelay,
            onSet: CardGridCallbacks.onSet,
            onNoSet: CardGridCallbacks.onNoSet,
            onCardsMoved: CardGridCallbacks.onCardsMoved
        )
    }

    public static func onSet(cards: [TableCard], resolve: @escaping () -> Void) {
        cards.blink {
            Delay(by: Defaults.Effects.selectAfterDelay) {
                resolve();
            }
        }
    }

    public static func onNoSet(cards: [TableCard], resolve: @escaping () -> Void) {
        cards.shake();
        resolve();
    }

    public static func onCardsMoved(cards: [TableCard]) {
        cards.flip(duration: 0.8);
    }
}

public struct TableCardEffects {
    // 
    // Techinical coding note/quirk: We must specify NO type (or Any type) for some
    // of the below because they have @escaping function arguments and there is no
    // way at all to represent a type specifier for these on a variable declaration.
    // 
    public var onSet                               = CardGridCallbacks.onSet;
    public var onNoSet                             = CardGridCallbacks.onNoSet;
    public var onCardsMoved: ([TableCard]) -> Void = CardGridCallbacks.onCardsMoved;
    public static let defaults: TableCardEffects = TableCardEffects();
};
