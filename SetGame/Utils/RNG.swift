import GameplayKit

// Simple wrapper to allow creating deterministic/repeatable random
// number if created with a specific seed value; useful, for example,
// for games where different clients need to generate the same random
// values in sequence as each other (e.g. like multi-player SET).
//
public class RNG {

    private let seed: UInt64?;
    private var rng: GKMersenneTwisterRandomSource?;

    public init(seed: UInt64? = nil) {
        if let seed: UInt64 = seed {
            self.seed = seed;
            self.rng = GKMersenneTwisterRandomSource(seed: seed);
        }
        else {
            self.seed = nil;
            self.rng = nil;
        }
    }

    public convenience init(seed: Int? = nil) {
        if let seed = seed { self.init(seed: UInt64(seed)); } else { self.init(seed: nil as UInt64?); }
    }

    public /*mutating*/ func reset() {
        if let seed: UInt64 = self.seed {
            self.rng = GKMersenneTwisterRandomSource(seed: seed);
        }
    }

    public func int(in range: Range<Int>) -> Int {
        if let rng = self.rng {
            let r = range.lowerBound + rng.nextInt(upperBound: range.upperBound - range.lowerBound);
            deb("RANDOM-A: \(r)")
            return r
        }
        else {
            let r = Int.random(in: range);
            deb("RANDOM-B: \(r)")
            return r
        }
    }

    public func int(in range: ClosedRange<Int>) -> Int {
        if let rng = self.rng {
            let r = range.lowerBound + rng.nextInt(upperBound: range.upperBound - range.lowerBound + 1);
            deb("RANDOM-C: \(r)")
            return r
        }
        else {
            let r = Int.random(in: range);
            deb("RANDOM-D: \(r)")
            return r
        }
    }

/*
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
*/
}
