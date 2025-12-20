import Foundation

/// Precomputed numbers of no-SET n-card subsets of a full (81 card) SET deck;
/// from Knuth's exhaustive enumeration; via ChatGPT.
///
private let _setlessCounts: [Int: UInt64] =
[
     1: 81,
     2: 3_240,
     3: 84_240,
     4: 1_579_500,
     5: 22_441_536,
     6: 247_615_056,
     7: 2_144_076_480,
     8: 14_587_567_020,
     9: 77_541_824_880,
    10: 318_294_370_368,
    11: 991_227_481_920,
    12: 2_284_535_476_080,
    13: 3_764_369_026_080,
    14: 4_217_827_554_720,
    15: 2_970_003_246_912,
    16: 1_141_342_138_404,
    17: 176_310_866_160,
    18: 6_482_268_000,
    19: 13_646_880,
    20: 682_344,
    21: 0
]

/// Same as above but for a simplified (27 card) SET deck.
///
private let _setlessCountsSimple: [Int: UInt64] = [
     0: 1,
     1: 27,
     2: 351,
     3: 2_808,
     4: 14_742,
     5: 50_544,
     6: 107_406,
     7: 126_360,
     8: 63_180,
     9: 2_106,
    10: 0,
]

extension Deck {

    public func xaverageNumberOfSets(_ ncards: Int, iterations: Int = 200) -> Float {
        if (ncards < 3) {
            return 0;
        }
        var totalSets = 0;
        for _ in 1...iterations {
            let deck: Deck = Deck(simple: self.simple);
            let cards: [T] = deck.takeRandomCards(ncards);
            totalSets += cards.numberOfSets();
        }
        return Float(totalSets) / Float(iterations);
    }

    public static func ncards(simple: Bool = false) -> Int {
        return simple ? 27 : 81;
    }

    public static func setlessCount(simple: Bool = false) -> Int {
        return simple ? 10 : 21;
    }

    private static func setlessCounts(simple: Bool = false) -> [Int: UInt64] {
        return simple ? _setlessCountsSimple : _setlessCounts;
    }

    /// Returns the average number of SETs in a deal of the given number of cards.
    ///
    public static func averageNumberOfSets(_ ncards: Int, iterations: Int = 100, simple: Bool = false) -> Float {
        if (ncards < 3) {
            return 0;
        }
        var totalSets = 0;
        for _ in 1...iterations {
            let deck: Deck = Deck(simple: simple);
            let cards: [T] = deck.takeRandomCards(ncards);
            totalSets += cards.numberOfSets();
        }
        return Float(totalSets) / Float(iterations);
    }

    /// Exact combinatorial probability (up to floating-point rounding) that
    /// a random n-card hand from a full 81-card SET deck contains at least one SET.
    ///
    /// - Parameter n: Number of cards in the hand (0...81).
    /// - Returns: Probability in [0, 1].
    //
    /// N.B. ChatGPT generated.
    ///
    public static func probabilityOfAtLeastOneSet(for ncards: Int, simple: Bool = false) -> Double {
        guard (ncards >= 3) && (ncards <= self.ncards(simple: simple)) else { return 0.0 }
        guard (ncards < Deck.setlessCount(simple: simple)) else { return 1.0 } // Max no-SET ncards is 20
        guard let setless = Deck.setlessCounts(simple: simple)[ncards] else {
            fatalError("Missing setless count for ncards = \(ncards)")
        }
        let totalHands = Math.binomial(self.ncards(simple: simple), ncards)
        let pNoSet = Double(setless) / totalHands
        return 1.0 - pNoSet
    }

    public static func numberOfDistinctSets(simple: Bool = false, ndifferences: Int = 0) -> Int
    {
        let nattributes: Int = simple ? 3 : 4
        let ncards: Int = self.ncards(simple: simple)
        let ndifferences: Int = min(max(ndifferences, 0), nattributes)

        if (ndifferences == 0) {
            //
            // Special case of ndifferences of zero means ANY differences;
            // i.e. effectively the sum of all of the defined cases.
            //
            return (ncards * (ncards - 1)) / 6;
        }

        return (
            Math.power(3, nattributes - 1) *
            Math.combinations(nattributes, ndifferences) * Math.power(2, ndifferences - 1)
        )
    }
}
