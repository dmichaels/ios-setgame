/// Array extension for convenience in handling simple Card arrays.
///
public extension Array where Element : Card {

    /// Adds the given card(s) to this array.
    ///
    public init(_ cards : Element...) {
        self = cards;
    }

    /// Creates an array of card(s) containgin cards specified by given string
    /// representations of cards to this array. Empty array of unparseable.
    ///
    public init(_ values : String) {
        self = Self.from(values);
    }

    public init(_ values : [String]) {
        self = Self.from(values);
    }

    /// Adds given card(s) to this array.
    ///
    public mutating func add(_ card : Element, _ cards : Element...) {
        self.append(card);
        self.append(contentsOf: cards);
    }

    public mutating func add(_ cards : [Element]) {
        self.append(contentsOf: cards);
    }

    /// Remove (all instances of the) given card(s) from this array.
    ///
    public mutating func remove(_ card : Element, _ cards  : Element...) {
        self.removeAll(where: {$0 == card});
        cards.forEach {
            let card = $0;
            self.removeAll(where: {$0 == card});
        }
    }

    public mutating func remove(_ cards : [Element]) {
        cards.forEach {
            let card = $0;
            self.removeAll(where: {$0 == card});
        }
    }

    public mutating func clear() {
        self.removeAll();
    }

    /// Removes and returns the first card from this array;
    /// returns nil if no more cards in the array.
    ///
    public mutating func takeCard() -> Element? {
        return self.count > 0 ? self.remove(at: 0) : nil;
    }

    /// Removes the (first instance of the) card matching the given card
    /// from this array and, if present and removed, returns the card,
    /// otherwise returns nil.
    ///
    public mutating func takeCard(_ card: Element) -> Element? {
        if let index: Int = firstIndex(of: card) {
            self.remove(at: index);
            return card;
        }
        return nil;
    }

    public mutating func takeCards(_ cards: [Element], strict: Bool = false) -> [Element]? {
        if (strict) {
            for card in cards {
                if (!self.contains(card)) {
                    return nil;
                }
            }
        }
        var result: [Element] = [];
        for card in cards {
            if let card: Element = self.takeCard(card) {
                result.append(card);
            }
        }
        return result;
    }

    /// Removes and returns a random card from this array;
    /// returns nil if no more cards in the array.
    ///
    public mutating func takeRandomCard() -> Element? {
        return (self.count > 0) ? self.remove(at: Int.random(in: 0..<self.count)) : nil;
    }

    /// Removes, at most, the specified number of random cards from this array, and returns these in
    /// a new array; if fewer cards are in this array than the number requested, then so be it, just
    /// that many will be returned (and then this array will end up being empty in this case).
    ///
    public mutating func takeRandomCards(_ n : Int) -> [Element] {
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
    public mutating func takeRandomCards(_ n : Int, plantSet: Bool, existingCards: [Element] = []) -> [Element] {
        guard (n > 0) && (self.count > 0) else { return [] }
        var randomCards: [Element] = [Element]();
        if (plantSet) {
            //
            // Here, we want to ensure, IF POSSIBLE, that the returned set of
            // cards (taken from this array of cards), TOGETHER/unioned with
            // any given set of existing cards contains at least one SET.
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
                    // Here, there are no SETs in the given set of existing cards; try to ensure,
                    // IF POSSIBLE, that the given set of existing cards, TOGETHER/unioned with
                    // cards to be returned (taken from this array) contains at least one SET.
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
                // Here, we want to take at least three cards from this array of cards,
                // and there are at least three cars in this array of cards.
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

    /// Returns (WITHOUT removal), at most, the specified number of random cards from this
    /// array, in a new array; if fewer cards are in this array than the that requested,
    /// then so be it, just that many will be returned, UNLESS the given strict argument
    /// is true, in which case an empty array will be returned in this case.
    ///
    /// N.B. Only (currently) used for the purpose of constructing a magic square.
    ///
    public func randomCards(_ n: Int, strict: Bool = false) -> [Element] {
        guard (n > 0) && (self.count > 0) else { return [] }
        let n: Int = Swift.min(n, self.count);
        let randomIndices = Array<Int>(0..<self.count).shuffled().prefix(n);
        var randomCards: [Element] = [];
        for i in randomIndices {
            randomCards.append(self[i]);
        }
        return randomCards;
    }

    /// Returns (WITHOUT removal) three random cards from this array which form a SET.
    /// If no such thing can be found then returns an empty array.
    ///
    public func randomSetCards() -> [Element] {
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

    /// Returns (without removal) three random cards from this array of cards, and returns these cards
    /// in a new array; but we ensure, IF POSSIBLE, there are NOT any SETs in the returned cards.
    /// If this is NOT POSSIBLE, either because there are not enough cards in this array of
    /// cards, or if they do not contain a non-SET of three, then an empty list is returned.
    /// Guaranteed: Return either an array of three cards which are a SET, or an empty array.
    ///
    /// N.B. Only (currently) used for the purpose of constructing a magic square.
    ///
    public func randomNonSetCards() -> [Element] {
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

    /// Returns true iff this array comprises a SET.
    ///
    public func isSet() -> Bool {
        return (self.count == 3) && Element.isSet(self[0], self[1], self[2]);
    }

    /// Returns true iff there exists at least one SET in this array.
    ///
    public func containsSet() -> Bool {
        var nsets: Int = 0;
        self.enumerateSets(limit: 1) { _ in nsets += 1; }
        return nsets > 0;
    }

    /// Returns the number of unique SETs in this array.
    ///
    public func numberOfSets(disjoint: Bool = false) -> Int {
        return self.enumerateSets(disjoint: disjoint).count;
    }

    /// Identifies/enumerates any/all SETs in this array and returns them in an array
    /// of array of cards, each representing a unique (possibily overlapping) SET
    /// within this array. The order of the returned array is in no particualr order.
    /// If the limit argument is greater than zero then the result set will be limited
    /// to a maximum of that number. If no SETs exist then returns an empty array.
    /// If the disjoint argument is true then the SETs identified will be limited
    /// to the maximum number of those which do not share any cards in common.
    ///
    /// One (possibly important -> moveAnyExistingSetToFront) assumption a caller
    /// CAN make WRT ordering: Though the order of the SETs returned is arbitrary,
    /// as mentioned, the order of the (three) cards WITHIN each SET is guaranteed
    /// to be in the order of their position in this array.
    ///
    /// FYI: The support for disjoint SETs was done with the help of ChatGPT, which
    /// claims that this is a "set-packing problem" which can be, in general, an
    /// NP-hard problem; but that for a small such as SET Game, a simple
    /// backtracking search provides a fast and accurate solution.
    ///
    private struct SetEnumerationCandidate {
        let mask: UInt64
        let set: [Element]
    }
    public func enumerateSets(limit: Int = 0, disjoint: Bool = false) -> [[Element]] {

        var sets: [[Element]] = [[Element]]();

        if (!disjoint) {
            //
            // Default case of non-disjoint (possibly overlapping) set of SETs.
            //
            self.enumerateSets(limit: limit) { sets.append($0); }
            return sets;
        }

        // Here we want the disjoint set of SETs (see above comment WRT ChatGPT). 

        if (self.count > 63) {
            //
            // Hard, and absolutely reasonably, upper bound of
            // 63 (for the UInt64 bit-mask) for what to look at.
            //
            return [];
        }

        self.enumerateSets() { sets.append($0); }

        // Convert each set to a bitmask of indices in
        // self (assumes cards are unique on the table).

        var candidates: [SetEnumerationCandidate] = [];

        candidates.reserveCapacity(sets.count);

        for set in sets {
            var mask: UInt64 = 0;
            var okay = true;
            for card in set {
                guard let index = self.firstIndex(of: card) else {
                    okay = false;
                    break;
                }
                mask |= (UInt64(1) << UInt64(index));
            }
            if (okay) {
                candidates.append(SetEnumerationCandidate(mask: mask, set: set));
            }
        }

        // Optional heuristic: Try more-constraining SETs first; since SET
        // sizes are always three, not so much; but still keeps it deterministic.

        candidates.sort { $0.mask.nonzeroBitCount > $1.mask.nonzeroBitCount }

        // Backtracking to find a maximum disjoint
        // collection, respecting limit if greater than zero.

        var best: [SetEnumerationCandidate] = [];
        var chosen: [SetEnumerationCandidate] = [];

        func depthFirstSearch(_ start: Int, _ used: UInt64) {
            if (chosen.count > best.count) {
                best = chosen; // update best
            }
            if ((limit > 0) && (best.count >= limit)) {
                return; // already hit target
            }
            if (start >= candidates.count) {
                return;
            }
            //
            // Simple upper-bound prune;
            // even taking everything remaining can't beat best.
            //
            let remaining = candidates.count - start;
            if ((chosen.count + remaining) <= best.count) {
                return;
            }
            for i in start..<candidates.count {
                let c = candidates[i];
                if ((used & c.mask) != 0) {
                    continue; // skip overlaps
                }
                chosen.append(c);
                depthFirstSearch(i + 1, used | c.mask);
                chosen.removeLast();
                if ((limit > 0) && (best.count >= limit)) {
                    return;
                }
            }
        }

        depthFirstSearch(0, 0);
        let result: [[Element]] = best.map { $0.set }
        return (limit > 0) ? result.prefix(limit).map { $0 } : result;
    }

    private func enumerateSets(limit: Int = 0, _ handler : ([Element]) -> Void) {
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

    /// If there is at least one SET in this array then move any single one of
    /// them (the SET of three cards) to the front of this array. Checks first
    /// to see if there already is a SET at the front, and if so does nothing.
    /// This is done while maximally maintaining the current positions of the
    /// cards in this array, and even choosing the any existing SET which
    /// already has the most cards in the top position.
    ///
    public mutating func moveAnyExistingSetToFront() {

        func findTargetSetIndices() -> [Int]? {

            let sets: [[Element]] = self.enumerateSets();

            guard !sets.isEmpty else {
                return nil;
            }

            var nfrontMax: Int = 0;
            var nfrontMaxSet: [Element] = [];
            for set in sets {
                var nfront: Int = 0;
                for card in set {
                    if let index: Int = self.firstIndex(where: {$0 == card}) {
                        if (index < 3) {
                            nfront += 1;
                        }
                    }
                }
                if (nfront > nfrontMax) {
                    nfrontMax = nfront;
                    nfrontMaxSet = set;
                }
            }

            let set: [Element] = (nfrontMax > 0) ? nfrontMaxSet : sets[0];

            func indices(cards: [Element]) -> [Int] {
                cards.compactMap { card in
                    self.firstIndex(of: card)
                }
            }

            return indices(cards: set);
        }

        if ((self.count > 3) && !Card.isSet(self[0], self[1], self[2])) {
            //
            // Here, we have more than three cards in this array
            // and the first three do NOT already comprise a SET.
            //
            if let setIndices: [Int] = findTargetSetIndices() {
                let setIndicesAboveSlot: [Int] = setIndices.filter { $0 >= 3 };
                let slotIndices: [Int] = [0, 1, 2].filter { !setIndices.contains($0) };
                for i in 0..<slotIndices.count {
                    self.swapAt(slotIndices[i], setIndicesAboveSlot[i]);
                }
            }
        }
    }

    func first(_ n: Int) -> [Element] {
        if (n > 0) {
            return Array(self.prefix(n));
        }
        else if (n < 0) {
            return Array(self.dropFirst(-n));
        }
        else {
            return [];
        }
    }

    func find(_ card: Element) -> Element? {
        return self.first(where: { $0 == card });
    }

    func find(_ cards: [Element]) -> [Element] {
        return self.filter { card in cards.contains(where: { $0 == card }) };
    }

    /// Parses and returns a card array representing given comma-separated list of
    /// string representations of SET cards. See Card.from for details of format.
    /// Unparsable items in the list are ignored; if no parsable card formats
    /// are found, then returns an empty array.
    ///
    public static func from(_ values : String) -> [Element] {
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
    public static func from(_ values : [String]) -> [Element] {
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
    public static func from(_ value : String) -> Element? {
        return Element(value);
    }
}
