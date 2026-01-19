import SwiftUI

extension Table {

    @MainActor
    public func demoCheck() async {
        if (self.settings.demoMode) {
            if (self.demoTimer == nil) {
                await self.demoStart();
            }
        }
        else if (self.demoTimer != nil) {
            self.demoStop();
        }
    }

    @MainActor
    public func demoStart() async {
        if (self.selectedCards().count > 0) {
            self.unselectCards();
        }
        if (self.gameDone()) {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            self.startNewGame();
        }
        else if (self.gameStart()) {
            try? await Task.sleep(nanoseconds: 800_000_000)
        }
        while (self.settings.demoMode) {
            if (self.gameDone()) {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                self.startNewGame();
            }
            await self.demoStep();
        }
    }

    @MainActor
    private func demoStop() {
        self.demoTimer?.invalidate();
        self.demoTimer = nil;
    }

    @MainActor
    private func demoStep() async {
        let sets: [[TableCard]] = self.enumerateSets(limit: 1);
        guard sets.count == 1 else { return }
        let set: [TableCard] = sets[0];
        try? await Task.sleep(nanoseconds: 300_000_000)
        for card in set {
            self.selectCard(card);
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        for card in set {
            self.cardTouched(
                card,
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
}
