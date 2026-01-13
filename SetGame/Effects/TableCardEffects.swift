import SwiftUI

struct TableCardEffects {

    public static func blinkCards(_ cards: [TableCard], times: Int = 3, interval: Double = 0.18,
                                    completion: @escaping () -> Void = {}) {

        // The interval is the time between blinks;
        // the lower the faster the blink.

        guard !cards.blinking else {
            return;
        }

        guard times > 0 else {
            completion();
            return;
        }

        var nblinks = times * 2; // times two because counting on/off

        cards.blinkingStart();

        func tick() {
            nblinks -= 1 ; if (nblinks <= 0) {
                cards.blinkingEnd();
                completion();
                return;
            }
            cards.blinkoffToggle();
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                tick();
            }
        }

        tick();
    }
}
