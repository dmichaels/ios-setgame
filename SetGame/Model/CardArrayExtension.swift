/// Array extension for convenience in handling simple Card arrays.
///
extension Array where Element : Card {

    /// Adds the given card(s) to this array.
    ///
    init(_ cards : Element...) {
        self = cards;
    }

    /// Creates an array of card(s) containgin cards specified by given string
    /// representations of cards to this array. Empty array of unparseable.
    ///
    init(_ values : String) {
        self = Self.from(values);
    }

    init(_ values : [String]) {
        self = Self.from(values);
    }

    /// Adds given card(s) to this array.
    ///
    mutating func add(_ card : Element, _ cards : Element...) {
        self.append(card);
        self.append(contentsOf: cards);
    }

    mutating func add(_ cards : [Element]) {
        self.append(contentsOf: cards);
    }

    /// Remove (all instances of the) given card(s) from this array.
    ///
    mutating func remove(_ card : Element, _ cards  : Element...) {
        self.removeAll(where: {$0 == card});
        cards.forEach {
            let card = $0;
            self.removeAll(where: {$0 == card});
        }
    }

    mutating func remove(_ cards : [Element]) {
        cards.forEach {
            let card = $0;
            self.removeAll(where: {$0 == card});
        }
    }

    mutating func clear() {
        self.removeAll();
    }

    /// Removes and returns the first card from this array;
    /// returns nil if no more cards in the array.
    ///
    mutating func takeCard() -> Element? {
        return self.count > 0 ? self.remove(at: 0) : nil;
    }

    /// Removes the (first instance of the) card matching the given card
    /// from this array and, if present and removed, returns the card,
    /// otherwise returns nil.
    ///
    mutating func takeCard(_ card: Element) -> Element? {
        if let index: Int = firstIndex(of: card) {
            self.remove(at: index);
            return card;
        }
        return nil;
    }

    /// FOR DEBUG/DEV ONLY!
    /// Returns (WITH removal) a set of cards from this array of cards, for the given
    /// list of SET card representations, if they are in this array; if not then just
    /// ignore/skip. Card representations of "S" are assigned a member of a SET,
    /// consecutively/iteratively, if possible; if possible then just ignore/skip.
    //
    mutating func takeCards(_ values: [String]) -> [Element] {
        var cards: [Element] = [];
        var sindices: [Int] = [];
        for i in 0..<values.count {
            if (values[i].uppercased() == "S") {
                cards.append(Element())
                sindices.append(i)
            }
            else if let card: Element = Self.from(values[i]) {
                if let card = self.takeCard(card) {
                    cards.append(card)
                }
            }
        }
        if (sindices.count > 0) {
            var set: [Element] = []
            var deletes: [Int] = []
            for i in sindices {
                if (set.count == 0) {
                    set = self.randomSetCards()
                }
                if (set.count > 0) {
                    cards[i] = set[0]
                    set.remove(at: 0)
                }
                else {
                    deletes.append(i)
                }
            }
            for i in deletes {
                cards.remove(at: i)
            }
        }
        return cards;
    }

    mutating func takeCards(_ values: String...) -> [Element] {
        return self.takeCards(values)
    }

    /// Removes and returns a random card from this array;
    /// returns nil if no more cards in the array.
    ///
    mutating func takeRandomCard() -> Element? {
        return (self.count > 0) ? self.remove(at: Int.random(in: 0..<self.count)) : nil;
    }

    /// Removes, at most, the specified number of random cards from this array, and returns these in
    /// a new array; if fewer cards are in this array than the number requested, then so be it, just
    /// that many will be returned (and then this array will end up being empty in this case).
    ///
    mutating func takeRandomCards(_ n : Int) -> [Element] {
        guard (n > 0) && (self.count > 0) else { return [] }
        var randomCards: [Element] = [Element]();
        for _ in 0..<n {
            if let randomCard: Element = self.takeRandomCard() {
                randomCards.add(randomCard)
            }
            else {
                break
            }
        }
        return randomCards;
    }

    /// Removes, at most, the specified number of random cards from this array, and returns these
    /// in a new array; if fewer cards are in this array than the number requested, then so be it,
    /// just that many will be returned (and then this array will end up being empty in this case).
    ///
    /// IF the plantSet argument is true THEN we will ensure, IF POSSIBLE, that the returned set of
    /// cards (taken from this array) contains at least one SET. BUT IF the existingCards argument is
    /// ALSO not empty, THEN instead we will ensure, IF POSSIBLE, that the given set of existing cards
    /// TOGETHER with the set of cards to be returned (taken from this array) contains at least one SET.
    ///
    /// The order of the returned cards (if any) will arbitrary/randomized.
    ///
    /// N.B. Please keep in mind that (normally) when our comments say "this array" here,
    /// we are talking about the deck of cards, and not the cards that are on the table.
    ///
    mutating func takeRandomCards(_ n : Int, plantSet: Bool, existingCards: [Element] = []) -> [Element] {
        guard (n > 0) && (self.count > 0) else { return [] }
        var randomCards: [Element] = [Element]();
        if (plantSet) {
            //
            // Here, we want to ensure, IF POSSIBLE, that the returned set of
            // cards (taken from this array of cards), TOGETHER (unioned with)
            // the given set of existing cards contains at least one SET.
            //
            if (existingCards.count > 0) {
                //
                // Here, there are given existing cards, which, TOGETHER with
                // the set of cards to be returned (taken from this array),
                // should (IF POSSIBLE) contains at least one SET.
                //
                let sets: [[Element]] = existingCards.enumerateSets(limit: 1)
                if (sets.count > 0) {
                    //
                    // Here, there is already (at least) one SET in the given set of existing cards;
                    // so simply take and return a random set of cards from this array of cards.
                    //
                    randomCards = self.takeRandomCards(n)
                }
                else {
                    //
                    // Here, there are no SETs in the given set of existing cards;
                    // try to ensure, IF POSSIBLE, that the given set of existing
                    // cards, TOGETHER with (unioned with) the set of cards to be
                    // returned (taken from this array) contains at least one SET.
                    //
                    for card in self {
                        let sets: [[Element]] = ([card] + existingCards).enumerateSets(limit: 1)
                        if (sets.count > 0) {
                            randomCards = [card]
                            self.remove(card);
                            break
                        }
                    }
                    randomCards.add(self.takeRandomCards(n - randomCards.count))
                }
            }
            else if ((n >= 3) && (self.count >= 3)) {
                ///
                // Here, we want to take at least 3 cards from this array of cards,
                // and there are at least 3 cars in this array of cards.
                ///
                let sets: [[Element]] = self.enumerateSets(limit: 1);
                if (sets.count > 0) {
                    //
                    // Here, there is (at least) one SET in this array of cards;
                    // so simply take and return this one SET.
                    //
                    randomCards = sets[0];
                    self.remove(randomCards);
                    if (n > 3) {
                        randomCards.add(self.takeRandomCards(n - 3))
                    }
                    randomCards.shuffle()
                }
                else {
                    //
                    // Here, there are no SETs in this array of cards.
                    //
                    randomCards = self.takeRandomCards(n)
                }
            }
            else {
                randomCards = self.takeRandomCards(n)
            }
        }
        else {
            //
            // Here, the simplest case of not wanting to plant any SETs; simply return
            // the specified number (IF POSSIBLE) of random cards from this array of cards. 
            //
            randomCards = self.takeRandomCards(n)
        }
        return randomCards;
    }

    /// Returns (WITH removal) 3 random cards (in a new array) from this array of cards,
    /// ENSURING that, IF POSSIBLE, there NO SETs in the returned cards. If this is NOT
    /// POSSIBLE (either because there are not enough cards in this array of cards, or if
    /// they do not contain a non-SET of 3), then returns and empty list (nothing removed).
    /// Guaranteed: Return either an array of 3 cards which are a SET, or an empty array;
    /// and if the former, then these 3 cards will be removed from this array of cards.
    ///
    /// N.B. Only (currently) used for the purpose of constructing a magic square.
    ///
    mutating func takeRandomNonSetCards() -> [Element] {
        let cards: [Element] = self.randomNonSetCards();
        guard cards.count == 3 else { return [] }
        self.remove(cards);
        return cards;
    }

    /// Returns (without removal), a random card from this array,
    /// or nil if this array is empty.
    ///
    func randomCard() -> Element? {
        return (self.count > 0) ? self[Int.random(in: 0..<self.count)] : nil;
    }

    /// Returns (WITHOUT removal), at most, the specified number of random cards from this
    /// array, in a new array; if fewer cards are in this array than the that requested,
    /// then so be it, just that many will be returned, UNLESS the given strict argument
    /// is true, in which case an empty array will be returned in this case.
    ///
    /// N.B. Only (currently) used for the purpose of constructing a magic square.
    ///
    func randomCards(_ n: Int, strict: Bool = false) -> [Element] {
        guard (n > 0) && (self.count > 0) else { return [] }
        let n: Int = Swift.min(n, self.count);
        let randomIndices = Array<Int>(0..<self.count).shuffled().prefix(n);
        var randomCards: [Element] = [];
        for i in randomIndices {
            randomCards.append(self[i]);
        }
        return randomCards;
    }

    /// Returns (WITHOUT removal) 3 random cards from this array which form a SET.
    /// If no such thing can be found then returns an empty array.
    ///
    func randomSetCards() -> [Element] {
        let randomIndices = Array<Int>(0..<self.count).shuffled();
        for i in 0..<(randomIndices.count - 2) {
            for j in (i + 1)..<(randomIndices.count - 1) {
                let ri: Int = randomIndices[i];
                let rj: Int = randomIndices[j];
                let rci: Element = self[ri];
                let rcj: Element = self[rj];
                let rcm: Element = Element(Card.matchingSetValue(rci, rcj))
                if (self.contains(rcm)) {
                    return [rci, rcj, rcm];
                }
            }
        }
        return [];
    }

    /// Returns (without removal) 3 random cards from this array of cards, and returns these cards
    /// in a new array; but we ensure, IF POSSIBLE, there are NOT any SETs in the returned cards.
    /// If this is NOT POSSIBLE, either because there are not enough cards in this array of
    /// cards, or if they do not contain a non-SET of 3, then an empty list is returned.
    /// Guaranteed: Return either an array of 3 cards which are a SET, or an empty array.
    ///
    /// N.B. Only (currently) used for the purpose of constructing a magic square.
    ///
    func randomNonSetCards() -> [Element] {
        guard self.count >= 3 else { return [] }
        var randomNonSetCards: [Element] = self.randomCards(2);
        let matchingSetCard = Card.matchingSetValue(randomNonSetCards[0], randomNonSetCards[1]);
        for randomIndex in Array<Int>(0..<self.count).shuffled() {
            let card: Element = self[randomIndex];
            if (!randomNonSetCards.contains(card) && (card != matchingSetCard)) {
                randomNonSetCards.append(card);
                return randomNonSetCards;
            }
        }
        return [];
    }

    func isSet() -> Bool {
        return (self.count == 3) && Element.isSet(self[0], self[1], self[2]);
    }

    func formsSetWith(_ a : Element, _ b : Element) -> Bool {
        return self.count == 1 && self[0].formsSetWith(a, b);
    }

    func formsSetWith(_ a : Element) -> Bool {
        return self.count == 2 && self[0].formsSetWith(self[1], a);
    }

    /// Returns true iff there exists at least one SET in this array.
    ///
    func containsSet() -> Bool {
        var nsets: Int = 0;
        self.enumerateSets(limit: 1) { _ in nsets += 1; }
        return nsets > 0;
    }

    /// Returns the number of unique SETs in this array.
    ///
    func numberOfSets() -> Int {
        var nsets: Int = 0;
        self.enumerateSets() { _ in nsets += 1; }
        return nsets;
    }

    /// Identifies/enumerates any/all SETs in this array and returns them in an array
    /// of array of cards, each representing a unique (possibily overlaping) SET
    /// within this array. If no SETs exist then returns an empty array.
    ///
    func enumerateSets(limit: Int = 0) -> [[Element]] {
        var sets: [[Element]] = [[Element]]();
        self.enumerateSets(limit: limit) { sets.append($0); }
        return sets;
    }

    func enumerateSets(limit: Int = 0, _ handler : ([Element]) -> Void) {
        var nsets: Int = 0;
        if (self.count > 2) {
            for i in 0..<(self.count - 2) {
                for j in (i + 1)..<(self.count - 1) {
                    for k in (j + 1)..<(self.count) {
                        let a: Element = self[i], b : Element = self[j], c : Element = self[k];
                        if (a.formsSetWith(b, c)) {
                            handler([a, b, c]);
                            nsets += 1;
                            if ((limit > 0) && (limit == nsets)) {
                                return;
                            }
                        }
                    }
                }
            }
        }
    }

    /// If there is at least one SET in this array then move any single
    /// one of them (the SET of three cards) to the front of this array.
    ///
    mutating func moveAnyExistingSetToFront() -> Bool {
        let sets: [[Element]] = self.enumerateSets(limit: 1);
        if (sets.count == 1) {
            for card in sets[0] {
                if let index: Int = self.firstIndex(where: {$0 == card}) {
                    self.remove(at: index);
                    self.insert(card, at: 0);
                }
            }
            return true;
        }
        return false;
    }

    /// Parses and returns a card array representing given comma-separated list of
    /// string representations of SET cards. See Card.from for details of format.
    /// Unparsable items in the list are ignored; if no parsable card formats
    /// are found, then returns an empty array.
    ///
    static func from(_ values : String) -> [Element] {
        return Self.from(
            values.filter  { !$0.isWhitespace }
                  .split() { $0 == "," }
                  .map     { String($0) }
        );
    }

    /// Parses and returns a card array representing given array of of string
    /// representations of SET cards. See Card.from for details of format.
    /// Unparsable items in the list are ignored; if no parsable card formats
    /// are found, then returns an empty array.
    ///
    static func from(_ values : [String]) -> [Element] {
        var cards: [Element] = [Element]();
        for value in values {
            if let card: Element = Element(value) {
                cards.add(card);
            }
        }
        return cards;
    }

    /// Parses and returns a card representing the given string
    /// representation of a SET card; If unparsable then returns nil.
    //
    static func from(_ value : String) -> Element? {
        return Element(value);
    }
}
