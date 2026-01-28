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
        if (Defaults.multiplayer.enabled) {
            GameCenter.HttpTransport.instance.send(
                message: GameCenter.FoundSetMessage(player: GameCenter.HttpTransport.instance.player, cards: cards));
            return;
        }
        cards.blink {
            Delay(by: Defaults.Effects.selectAfterDelay) {
                resolve();
            }
        }
    }

    public static func onSetMultiPlayer(cards: [TableCard], resolve: @escaping () -> Void) {
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
