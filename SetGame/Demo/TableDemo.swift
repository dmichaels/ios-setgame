import SwiftUI

@MainActor
public class TableDemo
{
    private var table: Table;
    private var settings: Settings;

    public init(table: Table, settings: Settings) {
        self.table = table;
        self.settings = settings;
    }

    @State var demoTimer: Timer? = nil;

    public func start() async {
        if (self.settings.demoMode) {
            if (self.demoTimer == nil) {
                await self.demoStart();
            }
        }
        else if (self.demoTimer != nil) {
            self.demoStop();
        }
    }

    public func demoStart() async {
        if (self.table.selectedCards().count > 0) {
            self.table.unselectCards();
        }
        if (self.table.gameDone()) {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            self.table.startNewGame();
        }
        else if (self.table.gameStart()) {
            try? await Task.sleep(nanoseconds: 800_000_000)
        }
        while (self.settings.demoMode) {
            if (self.table.gameDone()) {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                self.table.startNewGame();
            }
            await self.demoStep();
        }
    }

    private func demoStop() {
        self.demoTimer?.invalidate();
        self.demoTimer = nil;
    }

    private func demoStep() async {
        let sets: [[TableCard]] = self.table.enumerateSets(limit: 1);
        guard sets.count == 1 else { return }
        let set: [TableCard] = sets[0];
        try? await Task.sleep(nanoseconds: 300_000_000)
        for card in set {
            self.table.selectCard(card);
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        for card in set {
            CardGridCallbacks.cardTouched(card, table: self.table);
        }
    }
}
