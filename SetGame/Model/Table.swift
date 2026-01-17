import SwiftUI

/// Table represents a SET Game® table for (dis)play.
/// We mainly have a deck from which we deal, and the set/array of
/// table cards which are on display; and sundry other data points.
/// Is this class technically, effectively acting as a "model-view"?
///
public class Table: ObservableObject {

    public var settings: Settings;

    public struct State {

        fileprivate let table: Table;

        public var partialSetSelected: Bool            = false;
        public var incorrectGuessCount: Int            = 0;
        public var setsFoundCount: Int                 = 0;
        public var setJustFound: Bool                  = false;
        public var setJustFoundNot: Bool               = false;
        public var setsLastFound: [[TableCard]]               = [];
        public var showingCardsWhichArePartOfSet: Bool = false;
        public var showingOneRandomSet: Bool           = false;
        public var showingOneRandomSetLast: Int?       = nil;

        // This blinking flag is ONLY used to disable input while blinking the cards after
        // a SET is found (see allowsHitTesting in TableView); there should be a better way.
        //
        fileprivate var resolving: Bool = false;
        public      var newcomers: Set<TableCard.ID> = [];
        public      var nonset: Set<TableCard.ID> = [];
        public      var nonsetNonce: Int = 0

        public var blinking: Bool { self.table.cards.contains(where: { $0.blinking }) }
        public var disabled: Bool { self.table.state.blinking ||
                                       self.table.state.resolving ||
                                    self.table.settings.demoMode }
    }

    @Published private(set) var cards: [TableCard]!;
    @Published var state: State!;

    private var deck: TableDeck!;
    private var demoTimer: Timer? = nil;

    init(settings: Settings) {
        self.settings = settings;
        self.startNewGame();
    }

    func startNewGame() {

        self.deck  = TableDeck(simple: self.settings.simpleDeck);
        self.cards = [TableCard]();
        self.state = State(table: self);

        if (self.settings.plantMagicSquare && (self.settings.displayCardCount >= 9)) {
            let magicSquareCards: [TableCard] = TableDeck.randomMagicSquare(simple: self.settings.simpleDeck)
            if let cards: [TableCard] = self.deck.takeCards(magicSquareCards, strict: true) {
                self.cards.add(cards)
                self.noteNewcomers(cards);
            }
            //
            // Only bother making it look good if the cards-per-row is 4 (the default)
            // or 5; if cards-per-row is 3 it already falls out to look good automatically.
            //
            var displayCardCount: Int = self.settings.displayCardCount;
            if ((self.settings.cardsPerRow == 4) && (displayCardCount < 11)) {
                displayCardCount = 11;
            }
            else if ((self.settings.cardsPerRow == 5) && (displayCardCount < 13)) {
                displayCardCount = 13;
            }
            self.fillTable(moveSetFront: false, displayCardCount: displayCardCount);
            if (self.settings.cardsPerRow == 4) {
                self.cards[3]  = self.cards[9];
                self.cards[7]  = self.cards[10];
                self.cards[4]  = magicSquareCards[3];
                self.cards[5]  = magicSquareCards[4];
                self.cards[6]  = magicSquareCards[5];
                self.cards[8]  = magicSquareCards[6];
                self.cards[9]  = magicSquareCards[7];
                self.cards[10] = magicSquareCards[8];
            }
            else if (self.settings.cardsPerRow == 5) {
                self.cards[3]  = self.cards[9];
                self.cards[4]  = self.cards[10];
                self.cards[8]  = self.cards[11];
                self.cards[9]  = self.cards[12];
                self.cards[5]  = magicSquareCards[3];
                self.cards[6]  = magicSquareCards[4];
                self.cards[7]  = magicSquareCards[5];
                self.cards[10] = magicSquareCards[6];
                self.cards[11] = magicSquareCards[7];
                self.cards[12] = magicSquareCards[8];
            }
        }
        else {
            self.fillTable();
        }
    }

    /// Touch the given card; selects or unselects as appropriate.
    ///
    private func selectCard(_ card : TableCard) {

        if (!self.cards.contains(card)) {
            //
            // Given card isn't even on the table; no-op.
            // This should not happen!
            //
            return;
        }

        self.state.setJustFound = false;
        self.state.setJustFoundNot = false;

        if (self.state.showingCardsWhichArePartOfSet || self.state.showingOneRandomSet) {
            //
            // Three or more cards are already selected, due to selectAllCardsWhichArePartOfSet
            // showingOneRandomSet, as a result of calling selectAllCardsWhichArePartOfSet or
            // selectOneRandomSet; unselect all in this case.
            //
            self.unselectCards();
            self.state.showingCardsWhichArePartOfSet = false;
            self.state.showingOneRandomSet = false;
        }

        if (self.selectedCards().count >= 3) {
            //
            // NEVER allowed to have more than 3 cards selected; EXCEPT for the above special
            // case of showingCardsWhichArePartOfSet or showingOneRandomSet, as a result of
            // calling selectAllCardsWhichArePartOfSet or selectOneRandomSet.
            //
            return;
        }

        if (card.selected) {
            //
            // Selecting a selected cards unselects it.
            //
            card.selected = false;
            self.state.partialSetSelected = self.partialSetSelected();
            return;
        }

        // Select the given card.

        card.selected = true;
        self.state.partialSetSelected = self.partialSetSelected();
    }

    public func cardTouched(_ card : TableCard,
                              select: Bool = true,
                              delay: Double = 0.0,
                              callback: (([TableCard], Bool?, @escaping () -> Void) -> Void)? = nil) {

        guard !self.state.resolving else {
            //
            // We are already in the process of resolving a three-card selection;
            // this essentially makes this function non-reentrant, by setting the
            // state.resolving property during this process (function execution);
            // should not really get here because state.disabled is true in this
            // case in which disallows input (via allowsHitTesting in TableView).
            //
            return;
        }

        if (select) {
            //
            // This is the default case; we first actually put the
            // given card in a selected state; we don't do this the
            // demo-mode case, in which case we don't visually select
            // the SET first, rather we just do the blinking thing.
            //
            self.selectCard(card);
        }

        let selectedCards: [TableCard] = self.selectedCards();

        guard selectedCards.count == 3 else {
            //
            // We don't even have three cards selected; do nothing.
            // we still call the given callback (with nil argument meaning
            // three cards were not even selected); this allows the caller
            // to do something in this case, like make a tapping sound.
            //
            // The resolve function (see comments below) to this callback currently
            // does nothing; but maintain the documented requirement that it needs
            // to be called by the caller at the end of its processing, just in
            // case we later decide something else needs to be done/resolved.
            //
            callback?(selectedCards, nil, {});
            return;
        }

        // Here three cards are selected; we note that we are we are now resolving
        // this seleciton by setting the state.resolving property, which prevents
        // this function from being re-entered, and makes state.disabled true
        // which disallows input (via allowsHitTesting in TestView).

        self.state.resolving = true;

        func resolve() {
            self.resolveSet();
            self.state.resolving = false;
        }

        // Allowing a little delay gives us time to briefly see the cards
        // in a stable selected state, before moving on to deselect,
        // if no SET; or on to blinking, removing, and replacing, if SET.
        //
        // Note that the caller, if the callback argument is specified,
        // MUST call the given resolve function at the end of its processing.

        if (delay > 0) {
            // let delay: Double = selectedCards.isSet() ? delay / 2.0 : delay;
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let callback = callback {
                    callback(selectedCards, selectedCards.isSet(), resolve);
                }
                else {
                    resolve();
                }
            }
        }
        else if let callback = callback {
            callback(selectedCards, selectedCards.isSet(), resolve);
        }
        else {
            resolve();
        }
    }

    /// Checks whether or not a SET is currently selected on the table.
    /// If a SET is selected, then removes these selected SET cards and
    /// replaces them with new ones from the deck (in an unselected state),
    /// If a non-SET is selected (i.e. three cards selected but which do
    /// not form SET), then these cards will simply be unselected.
    ///
    private func resolveSet() {

        let selectedCards: [TableCard] = self.selectedCards();

        guard selectedCards.count == 3 else {
            //
            // Three cards are not even selected; do nothing.
            //
            return;
        }

        // We have three cards selected; now see if
        // we have a SET selected, or a wrong guess.

        if (selectedCards.isSet()) {
            //
            // We have a SET!
            // Unselect the SET cards, calling the given callback if any,
            // and then remove these SET cards from the table,
            // and replace them with cards from the deck.
            //
            self.state.setsFoundCount += 1;
            self.state.setJustFound = true;
            //
            // 2025-12-12
            // Better code which replaces selected SET cards minimum reordering,
            // and with reversion toward the preferred number of display cards.
            // Slightly tricky to get just right; be careful.
            //
            let extraCardsTotal: Int = max(self.cards.count - self.settings.displayCardCount, 0);
            let extraCardsUnsel: [TableCard] = self.cards.suffix(extraCardsTotal).filter { !$0.selected };
            let extraCardsCount: Int = min(extraCardsUnsel.count, 3);
            let extraCards: [TableCard] = extraCardsUnsel.suffix(extraCardsCount).reversed();
            let newCardsCount: Int = 3 - min(extraCardsTotal, 3);
            let newCards: [TableCard] = newCardsCount <= 0 ? [] : (
                self.deck.takeRandomCards(
                    newCardsCount,
                    plantSet: self.settings.plantSet,
                    existingCards: self.settings.plantSet ? self.cards.filter { !$0.selected } : []
                )
            );
            var replacementCards: [TableCard] = extraCards + newCards;
            var deletionIndices: [Int] = []
            for i in 0..<self.cards.count {
                if (self.cards[i].selected) {
                    if (replacementCards.count > 0) {
                        self.cards[i] = replacementCards[0];
                        replacementCards.remove(at: 0);
                    }
                    else {
                        deletionIndices.append(i);
                    }
                }
            }
            self.cards.removeLast(3 - newCardsCount);
            for deletionIndex in deletionIndices.reversed() {
                if (deletionIndex < self.cards.count) {
                    self.cards.remove(at: deletionIndex);
                }
            }
            //
            // Fill just in case we have fewer cards than
            // what is normally desired; and unselect all.
            //
            self.unselectCards()
            self.fillTable();
            self.addToSetsLastFound(selectedCards);
            self.noteNewcomers(newCards);
        }
        else {
            //
            // We do NOT have a SET :-(
            //
            self.noteIncorrectGuess(selectedCards);
            self.unselectCards();
        }
    }

    private func addToSetsLastFound(_ cards: [TableCard]) {
        //
        // IMPORTANT NOTE:
        // We must reset the (UI related) state of TableCard,
        // e.g. selected and materializedOnce, here so that
        // the special materializeOnce gets reset.
        //
        cards.reset();
        self.state.setsLastFound.append(cards);
    }

    private func noteIncorrectGuess(_ cards: [TableCard]) {
        self.state.setJustFoundNot = true;
        self.state.incorrectGuessCount += 1;
        let ids: Set<TableCard.ID> = Set(cards.map(\.id));
        self.state.nonset = ids;
        self.state.nonsetNonce += 1;
        let delay: Double = 0.35;
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if (self.state.nonset == ids) {
                self.state.nonset.removeAll();
            }
        }
    }

    private func noteNewcomers(_ cards: [TableCard], randomize: Bool = true) {
        if (randomize) {
            for card in cards {
                let delay: Double = Double.random(in: 0.20...0.60);
                self.state.newcomers.formUnion([card.id]);
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.state.newcomers.subtract([card.id]);
                }
            }
        }
        else {
            let ids: Set<TableCard.ID> = Set(cards.map(\.id));
            self.state.newcomers.formUnion(ids);
            let delay: Double = 4.2;
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.state.newcomers.subtract(ids);
            }
        }
    }

    func selectAllCardsWhichArePartOfSet() {
        self.unselectCards();
        let sets: [[TableCard]] = self.enumerateSets();
        for set in sets {
            for card in set {
                card.selected = true;
            }
        }
    }

    func selectOneRandomSet(disjoint: Bool = false) {
        self.unselectCards();
        let sets: [[TableCard]] = self.enumerateSets(disjoint: disjoint);
        if (sets.count > 0) {
            if (self.state.showingOneRandomSetLast == nil) {
                //
                // Actually not random any more (circa December 2025)
                // since we are now cycling through them deterministically.
                // self.state.showingOneRandomSetLast = Int.random(in: 0..<sets.count);
                //
                self.state.showingOneRandomSetLast = 0;
            }
            else if (self.state.showingOneRandomSetLast! < (sets.count - 1)) {
                self.state.showingOneRandomSetLast = self.state.showingOneRandomSetLast! + 1
            }
            else {
                self.state.showingOneRandomSetLast = 0
            }
            let set: [TableCard] = sets[self.state.showingOneRandomSetLast!];
            for card in set {
                card.selected = true;
            }
        }
        else {
            self.state.showingOneRandomSetLast = nil
        }
    }

    func unselectCards() {
        for card in self.cards {
            card.selected = false;
        }
    }

    /// Returns the set (array) of currently selected cards.
    ///
    func selectedCards() -> [TableCard] {
        return self.cards.filter { $0.selected };
    }

    /// Returns the number of currently selected cards.
    ///
    func selectedCardCount() -> Int {
        return self.selectedCards().count;
    }

    /// Returns true iff there is at least one SET present on the table.
    ///
    func containsSet() -> Bool {
        return self.cards.containsSet();
    }

    /// Returns the number SETs present on the table.
    ///
    func numberOfSets(disjoint: Bool = false) -> Int {
        return self.cards.numberOfSets(disjoint: disjoint);
    }

    /// Identifies/enumerates any/all SETs present on this table,
    /// and returns them in an array of array of cards, each being
    /// a unique (possibily overlaping) SET within the table cards.
    /// If no SETs exist then returns an empty array.
    ///
    func enumerateSets(limit : Int = 0, disjoint: Bool = false) -> [[TableCard]] {
        return self.cards.enumerateSets(limit: limit, disjoint: disjoint);
    }

    /// Returns the number of cards remaining in the deck.
    ///
    func remainingCardCount() -> Int {
        return self.deck.count;
    }

    /// Returns true iff the currently selected cards form a partial SET.
    ///
    func partialSetSelected() -> Bool {
        let selectedCards: [TableCard] = self.selectedCards();
        if (selectedCards.count == 1) {
            let cardA: TableCard = selectedCards[0];
            let sets: [[TableCard]] = self.enumerateSets();
            for set in sets {
                if (set.contains(cardA)) {
                    return true;
                }
            }
        }
        else if (selectedCards.count == 2) {
            let cardA: TableCard = selectedCards[0];
            let cardB: TableCard = selectedCards[1];
            let sets: [[TableCard]] = self.enumerateSets();
            for set in sets {
                if (set.contains(cardA) && set.contains(cardB)) {
                    return true;
                }
            }
        }
        return false;
    }

    /// Move a SET (if any) which may exist in the table cards to the front (top-left) of the table
    /// cards array; check first to see if there already is a SET at the front, and if so do nothing.
    ///
    func moveAnyExistingSetToFront() {
        if ((self.cards.count > 3) && !Card.isSet(self.cards[0], self.cards[1], self.cards[2])) {
            self.cards.moveAnyExistingSetToFront();
        }
    }

    /// Adds (at most) the given number of cards to the table from the deck.
    ///
    func addMoreCards(_ ncards: Int, plantSet: Bool? = nil) {
        guard (ncards > 0) && (self.deck.count > 0) else { return; }
        let plantSet: Bool = plantSet ?? self.settings.plantSet;
        if (plantSet && !self.containsSet() && (self.cards.count + min(self.deck.count, ncards)) >= 3) {
            //
            // If we want a SET planted, and only if there are not already any
            // SETs on the table, and only if there are enough cards between
            // what's on the table and what we're adding and what's left in
            // the deck, then try to plant a SET with these newly added cards.
            //
            if (ncards >= 3) {
                //
                // Trivial case; no SETs on the table and adding 3 or more
                // cards; just try to ensure the random 3+ cards taken
                // from the deck contain a SET.
                //
                let cards: [TableCard] = self.deck.takeRandomCards(ncards, plantSet: true);
                self.cards.add(cards);
                self.noteNewcomers(cards);
            }
            else {
                //
                // Not so trivial case; check each pair (of 2) cards on
                // the table, see if there's a matching card in the deck,
                // and if so, include that in the cards added to the table.
                //
                for i in 0..<(self.cards.count - 1) {
                    for j in (i + 1)..<(self.cards.count) {
                        let a: TableCard = self.cards[i];
                        let b: TableCard = self.cards[j];
                        let c: TableCard = TableCard(TableCard.matchingSetValue(a, b));
                        if let c = self.deck.takeCard(c) {
                            self.cards.add(c);
                            self.noteNewcomers([c]);
                            self.addMoreCards(ncards - 1, plantSet: false);
                        }
                    }
                }
            }
        }
        else {
            let cards: [TableCard] = self.deck.takeRandomCards(ncards);
            self.cards.add(cards);
            self.noteNewcomers(cards);
        }
    }

    /// Populate the table cards from the deck up to the displayCardCount.
    /// If the moreCardsIfNoSet flag is set then if we don't have a SET on
    /// the table, then add up to 3 more cards.
    ///
    private func fillTable(moveSetFront: Bool? = nil, displayCardCount: Int? = nil) {
        let displayCardCount: Int = displayCardCount ?? self.settings.displayCardCount;
        self.addMoreCards(displayCardCount - self.cards.count);
        if (self.settings.additionalCards > 0) {
            while (!self.containsSet()) {
                if (self.deck.count == 0) {
                    break;
                }
                self.addMoreCards(self.settings.additionalCards);
            }
        }
        if (moveSetFront ?? self.settings.moveSetFront) {
            self.moveAnyExistingSetToFront();
        }
    }

    public func gameStart() -> Bool {
        return self.state.setsLastFound.count == 0;
    }

    public func gameDone() -> Bool {
        return (self.deck.count == 0) && !self.containsSet();
    }

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
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            self.startNewGame();
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
                    self.cardTouched(card, select: false, delay: 0.5) { cards, set, resolve in
                        if let set: Bool = set, set {
                            cards.blink() {
                                resolve();
                            }
                        }
                        else {
                            resolve();
                        }
                    }
                }
                try? await Task.sleep(nanoseconds: 800_000_000)
            }
        }
    }
}
