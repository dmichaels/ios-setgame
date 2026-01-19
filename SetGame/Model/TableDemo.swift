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
        if (self.cards.count > 0) {
            let sets: [[TableCard]] = self.enumerateSets(limit: 1);
            if (sets.count == 1) {
                let set: [TableCard] = sets[0];
                for card in set {
                    self.selectCard(card);
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
                for card in set {
                    self.cardTouched(
                        card,
                        select: false,
                        delay: 0.8,
                        onSet: { cards, resolve in
                            cards.blink() {
                                resolve();
                            }
                        },
                        onNoSet: { cards, resolve in
                            cards.shake();
                            resolve();
                        },
                        onCardsMoved: { cards in
                            cards.flip();
                        }
                    )
                }
                try? await Task.sleep(nanoseconds: 800_000_000)
            }
        }
    }
}
