public extension Array where Element : Card {

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
}
