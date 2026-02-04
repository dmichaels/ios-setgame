import GameplayKit

// Simple wrapper to allow creating deterministic/repeatable random
// number if created with a specific seed value; useful, for example,
// for games where different clients need to generate the same random
// values in sequence as each other (e.g. like multi-player SET).
//
public struct Random {

    private let rng: GKMersenneTwisterRandomSource?

    public init(seed: UInt64? = nil) {
        if let seed: UInt64 = seed {
            self.rng = GKMersenneTwisterRandomSource(seed: seed);
        }
        else {
            self.rng = nil;
        }
    }

    public func int(in range: Range<Int>) -> Int {
        if let rng = self.rng {
            return range.lowerBound + rng.nextInt(upperBound: range.upperBound - range.lowerBound);
        }
        else {
            return Int.random(in: range);
        }
    }

    public func int(in range: ClosedRange<Int>) -> Int {
        if let rng = self.rng {
            return range.lowerBound + rng.nextInt(upperBound: range.upperBound - range.lowerBound + 1);
        }
        else {
            return Int.random(in: range);
        }
    }
}
