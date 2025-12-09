import SwiftUI

/// Table represents a SET Game® table for (dis)play.
/// We mainly have a deck from which we deal, and the set/array of
/// table cards which are on display; and sundry other data points.
/// Is this class technically, effectively acting as a "model-view"?
///
class Table<TC : TableCard> : ObservableObject {

    class Settings {
        //
        // Something I really don't understand yet ...
        // Needed to make this a class and not a struct because on the didSet
        // for moreCardsIfNoSet, though if when it's true, it is not true within
        // the call to fillTable, which checks this value ... Why not? Is this
        // not the same instance, or the same copy it ? Guess not. A thinker.
        //
        var table                           : Table?;
        var preferredDisplayCardCount       : Int  = 12;
        var limitDeckSize                   : Int  = Deck().count;
        var cardsPerRow                     : Int  = 4;
        var useSimpleDeck                   : Bool = false {
            didSet {
                //
                // 2025-12-08
                // No longer automatically restart when requesting simplifed deck in settings.
                //
                // self.table?.startNewGame();
            }
        }
        var plantSet                        : Bool = false;
        var plantInitialMagicSquare         : Bool = false
        var moreCardsIfNoSet                : Bool = false {
            didSet {
                if (self.moreCardsIfNoSet) {
                    self.table?.fillTable();
                }
            }
        }
        var showPartialSetSelectedIndicator : Bool = true;
        var showNumberOfSetsPresent         : Bool = true;
        var moveAnyExistingSetToFront       : Bool = false {
            didSet {
                if (self.moveAnyExistingSetToFront) {
                    self.table?.moveAnyExistingSetToFront();
                }
            }
        }
    }

    struct State {
        var partialSetSelected            : Bool = false;
        var incorrectGuessCount           : Int  = 0;
        var setsFoundCount                : Int  = 0;
        var setJustFound                  : Bool = false;
        var setJustFoundNot               : Bool = false;
        var setLastFound                  : [TC] = [TC]();
        var showingCardsWhichArePartOfSet : Bool = false;
        var showingOneRandomSet           : Bool = false;
        var showingOneRandomSetLast       : Int? = nil;
    }

                      private      var deck     : Deck<TC>;
    @Published public private(set) var cards    : [TC];
    @Published                     var state    : State;
    @Published                     var settings : Settings;

    init(preferredDisplayCardCount : Int = 9, plantSet : Bool = false) {
        self.deck                        = Deck();
        self.cards                       = [TC]();
        self.state                       = State();
        self.settings                    = Settings();
        self.settings.preferredDisplayCardCount = preferredDisplayCardCount;
        self.settings.plantSet           = plantSet;
        self.settings.table              = self;
        self.fillTable();
    }

    func startNewGame() {
        self.deck  = Deck(simple: self.settings.useSimpleDeck, ncards: self.settings.limitDeckSize);
        self.cards = [TC]();
        self.state = State();
        if (self.settings.plantInitialMagicSquare && (self.settings.preferredDisplayCardCount >= 9)) {
            let magicSquareCards: [Card] = Deck.randomMagicSquare()
            for card in magicSquareCards {
                self.cards.add(TC(card))
                _ = self.deck.takeCard(TC(card))
            }
            //
            // Only bother making it look good if the cards-per-row is 4 (the default)
            // or 5; if cards-per-row is 3 it already falls out to look good automatically.
            //
            let preferredDisplayCardCountSave: Int = self.settings.preferredDisplayCardCount
            if ((self.settings.cardsPerRow == 5) && (self.settings.preferredDisplayCardCount < 13)) {
                self.settings.preferredDisplayCardCount = 13
            }
            self.fillTable(frontSet: false);
            self.settings.preferredDisplayCardCount = preferredDisplayCardCountSave
            if (self.settings.cardsPerRow == 4) {
                self.cards[3]  = self.cards[9]
                self.cards[7]  = self.cards[10]
                self.cards[4]  = TC(magicSquareCards[3])
                self.cards[5]  = TC(magicSquareCards[4])
                self.cards[6]  = TC(magicSquareCards[5])
                self.cards[8]  = TC(magicSquareCards[6])
                self.cards[9]  = TC(magicSquareCards[7])
                self.cards[10] = TC(magicSquareCards[8])
            }
            else if (self.settings.cardsPerRow == 5) {
                self.cards[3]  = self.cards[9]
                self.cards[4]  = self.cards[10]
                self.cards[8]  = self.cards[11]
                self.cards[9]  = self.cards[12]
                self.cards[5]  = TC(magicSquareCards[3])
                self.cards[6]  = TC(magicSquareCards[4])
                self.cards[7]  = TC(magicSquareCards[5])
                self.cards[10] = TC(magicSquareCards[6])
                self.cards[11] = TC(magicSquareCards[7])
                self.cards[12] = TC(magicSquareCards[8])
            }
        }
        else {
            self.fillTable();
        }
    }

    private func findTableDuplicates() {
        //
        // FOR DEBUGGING ONLY!
        //
        for i in 0..<(self.cards.count - 1) {
            for j in (i + 1)..<(self.cards.count) {
                let a: TC = self.cards[i];
                let b: TC = self.cards[j];
                if (a == b) {
                    print("DUPLICATE!")
                    print(a)
                }
            }
        }
    }

    /// Touch the given card; selects or unselects as appropriate.
    ///
    func touchCard(_ card : TC) {

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
            // Three or more cards selected; presumably
            // due to selectAllCardsWhichArePartOfSet;
            // unselect all.
            //
            self.unselectCards();
            self.state.showingCardsWhichArePartOfSet = false;
            self.state.showingOneRandomSet = false;
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

    /// Checks whether or not a SET is currently selected on the table.
    /// If a SET is selected, then removes these selected SET cards and
    /// replaces them with new ones from the deck (in an unselected state).
    /// If a non-SET is selected (i.e. three cards selected but which do
    /// not form SET), then these cards will simply be unselected.
    ///
    func checkForSet() {

        let selectedCards: [TC] = self.selectedCards();

        // See if we have a SET selected now.

        if (selectedCards.count == 3) {
            //
            // Here we either have a SET selected or a wrong guess.
            //
            if (selectedCards.isSet()) {
                //
                // SET!
                // Unselect the SET cards, calling the given callback if any,
                // and then remove these SET cards from the table,
                // and replace them with cards from the deck.
                //
                self.state.setsFoundCount += 1;
                self.state.setJustFound = true;
                self.state.setLastFound = selectedCards;
                if (false) {
                    //
                    // 2025-12-06
                    // Olde code which did not simply replace existing set cards in place;
                    // so it was re-ordering the cards on the table when not necessary.
                    //
                    self.unselectCards(selectedCards, set: true);
                    self.cards.remove(selectedCards);
                    self.fillTable();
                }
                else {
                    //
                    // 2025-12-06
                    // Newer code which replaces SET cards without re-ordering.
                    // N.B. But this does NOT respect the plantSet option; do we really even want that.
                    //
                    let extraCardsShowingCount: Int = max(self.cards.count - self.settings.preferredDisplayCardCount, 0)
                    let newCards: [TC] = self.deck.takeRandomCards(
                        3 - max(self.cards.count - self.settings.preferredDisplayCardCount, 0),
                        plantSet: self.settings.plantSet,
                        existingCards: self.settings.plantSet ? self.cards.filter { !$0.selected } : []
                    );
                    var newCardIndex: Int = 0
                    var cardIndex: Int = 0
                    var deletedCardIndices: [Int] = []
                    for card in self.cards {
                        if (card.selected) {
                            if (newCardIndex < newCards.count) {
                                self.cards[cardIndex] = newCards[newCardIndex]
                                newCardIndex += 1
                            }
                            else {
                                deletedCardIndices.append(cardIndex)
                            }
                        }
                        cardIndex += 1
                    }
                    if (deletedCardIndices.count > 0) {
                        for i in stride(from: deletedCardIndices.count - 1, through: 0, by: -1) {
                            self.cards.remove(at: deletedCardIndices[i])
                        }
                    }
                    //
                    // Fill just in case we have fewer cards than what is normally desired.
                    //
                    self.unselectCards()
                    self.fillTable();
                }
            }
            else {
                //
                // Dummy :-(
                //
                self.state.setJustFoundNot = true;
                self.state.incorrectGuessCount += 1;
                self.unselectCards();
            }
        }
    }

    func selectAllCardsWhichArePartOfSet() {
        self.unselectCards();
        let sets: [[TC]] = self.enumerateSets();
        for set in sets {
            for card in set {
                card.selected = true;
            }
        }
    }

    func selectOneRandomSet() {
        self.unselectCards();
        let sets: [[TC]] = self.enumerateSets();
        if (sets.count > 0) {
            if (self.state.showingOneRandomSetLast == nil) {
                self.state.showingOneRandomSetLast = Int.random(in: 0..<sets.count);
            }
            else if (self.state.showingOneRandomSetLast! < (sets.count - 1)) {
                self.state.showingOneRandomSetLast = self.state.showingOneRandomSetLast! + 1
            }
            else {
                self.state.showingOneRandomSetLast = 0
            }
            let set: [TC] = sets[self.state.showingOneRandomSetLast!];
            for card in set {
                card.selected = true;
            }
        }
        else {
            self.state.showingOneRandomSetLast = nil
        }
    }

    /// Unselects all cards.
    ///
    func unselectCards(set: Bool = false) {
        self.unselectCards(self.cards, set: set);
    }

    /// Unselects the given cards (could be static).
    /// If the set parameter is true then mark the card as part of a SET.
    ///
    private func unselectCards(_ cards    : [TC],
                                 set      : Bool = false) {
        cards.forEach {
            let card: TC = $0;
            card.selected = false;
            if (set) {
                card.set = true;
            }
        }
    }

    /// Returns the set (array) of currently selected cards.
    ///
    func selectedCards() -> [TC] {
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
    func numberOfSets() -> Int {
        return self.cards.numberOfSets();
    }

    /// Identifies/enumerates any/all SETs present on this table,
    /// and returns them in an array of array of cards, each being
    /// a unique (possibily overlaping) SET within the table cards.
    /// If no SETs exist then returns an empty array.
    ///
    func enumerateSets(limit : Int = 0) -> [[TC]] {
        return self.cards.enumerateSets(limit: limit);
    }

    /// Returns the number of cards remaining in the deck.
    ///
    func remainingCardCount() -> Int {
        return self.deck.count;
    }

    /// Returns true iff the currently selected cards form a partial SET.
    ///
    func partialSetSelected() -> Bool {
        let selectedCards: [TC] = self.selectedCards();
        if (selectedCards.count == 1) {
            let cardA: TC = selectedCards[0];
            let sets: [[TC]] = self.enumerateSets();
            for set in sets {
                if (set.contains(cardA)) {
                    return true;
                }
            }
        }
        else if (selectedCards.count == 2) {
            let cardA: TC = selectedCards[0];
            let cardB: TC = selectedCards[1];
            let sets: [[TC]] = self.enumerateSets();
            for set in sets {
                if (set.contains(cardA) && set.contains(cardB)) {
                    return true;
                }
            }
        }
        return false;
    }

    /// Move and SET which might exist in the table cards
    /// to the front of the cards list/array.
    ///
    func moveAnyExistingSetToFront() {
        _ = self.cards.moveAnyExistingSetToFront();
    }

    /// Adds (at most) the given number of cards to the table from the deck.
    ///
    func addMoreCards(_ ncards : Int, plantSet : Bool? = nil, frontSet: Bool? = nil) {
        guard (ncards > 0) && (self.deck.count > 0) else { return; }
        // let plantSet: Bool = (plantSet == nil) ? self.settings.plantSet : plantSet!;
        let plantSet: Bool = plantSet ?? self.settings.plantSet;
        let frontSet: Bool = frontSet ?? self.settings.moveAnyExistingSetToFront;
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
                self.cards.add(self.deck.takeRandomCards(ncards, plantSet: true));
            }
            else {
                //
                // Not so trivial case; check each pair (of 2) cards on
                // the table, see if there's a matching card in the deck,
                // and if so, include that in the cards added to the table.
                //
                for i in 0..<(self.cards.count - 1) {
                    for j in (i + 1)..<(self.cards.count) {
                        let a: TC = self.cards[i];
                        let b: TC = self.cards[j];
                        let c: TC = TC(Card.matchingSetValue(a, b));
                        if let c = self.deck.takeCard(c) {
                            self.cards.add(c);
                            self.addMoreCards(ncards - 1, plantSet: false, frontSet: frontSet);
                        }
                    }
                }
            }
        }
        else {
            self.cards.add(self.deck.takeRandomCards(ncards));
        }
        if (frontSet) {
            self.moveAnyExistingSetToFront();
        }
    }

    /// Populate the table cards from the deck up to the preferredDisplayCardCount.
    /// If the moreCardsIfNoSet flag is set then if we don't have a SET on
    /// the table, then add up to 3 more cards.
    ///
    private func fillTable(frontSet: Bool? = nil) {
        self.addMoreCards(self.settings.preferredDisplayCardCount - self.cards.count, frontSet: frontSet);
        if (self.settings.moreCardsIfNoSet) {
            while (!self.containsSet()) {
                if (self.deck.cards.count == 0) {
                    break;
                }
                self.addMoreCards(1, frontSet: frontSet);
            }
        }
    }
}
