import GameplayKit

// Simple wrapper to allow creating deterministic/repeatable random
// number if created with a specific seed value; useful, for example,
// for games where different clients need to generate the same random
// values in sequence as each other (e.g. like multi-player SET).
//
public class RNG {

    public static let fallback: RNG = RNG(seed: nil);

    private var seed: UInt64?;
    private var rng: GKMersenneTwisterRandomSource?;

    public enum SeedType {
        case random;
        case initial;
        case none;
    }

    /// Initalizes the RNG to use the given seed value.
    ///
    public init(seed: UInt64) {
        self.seed = seed;
        self.rng = GKMersenneTwisterRandomSource(seed: seed);
    }

    /// If the given value is not nil then initalizes the RNG to use a
    /// randomly generated seed value. If the given value is nil then
    /// initializes to not use a custom RNG at all.
    ///
    public init(seed: Int?) {
        if let seed: Int = seed {
            self.seed = RNG.convertIntToUInt64(seed);
            self.rng = GKMersenneTwisterRandomSource(seed: self.seed!);
        }
        else {
            self.seed = nil;
            self.rng = nil;
        }
    }

    /// If seed is .random or .initial then initializes the RNG use a randomly
    // generated seed value. If seed is .initial then initializes to not use a
    // custom RNG at all. 
    ///
    public convenience init(seed: SeedType) {
        switch seed {
            case .random:  self.init(seed: UInt64.random(in: 1...UInt64.max));
            case .initial: self.init(seed: UInt64.random(in: 1...UInt64.max));
            case .none:    self.init(seed: nil);
        }
    }

    /// Initializes the RNG use a randomly generated seed value.
    ///
    public convenience init() {
        self.init(seed: .random);
    }

    /// Resets the RNG to use the given seed value.
    ///
    public func reset(seed: UInt64) {
        self.seed = seed;
        self.rng = GKMersenneTwisterRandomSource(seed: seed);
    }

    /// If the given value is not nil then resets the RNG to use a
    /// randomly generated seed value. If the given value is nil
    /// then resets to not use a custom RNG at all.
    ///
    public func reset(seed: Int?) {
        if let seed: Int = seed {
            self.reset(seed: RNG.convertIntToUInt64(seed));
        }
        else {
            self.seed = nil;
            self.rng = nil;
        }
    }

    /// If seed is .random then resets the RNG to use a randomly generated seed value.
    /// If seed is .initial then resets the RNG to use the previously defined value, if any.
    /// If seed is .none then resets to not use a custom RNG at all. 
    ///
    public func reset(seed: SeedType) {
        switch seed {
            case .random:  self.reset(seed: UInt64.random(in: 1...UInt64.max));
            case .initial: self.reset();
            case .none:    self.reset(seed: nil);
        }
    }

    /// Resets the RNG to use the previously defined seed, if any.
    ///
    public func reset() {
        if let seed: UInt64 = self.seed {
            self.rng = GKMersenneTwisterRandomSource(seed: seed);
        }
    }

    public func next() -> Int {
        return self.next(in: 0...Int.max);
    }

    public func next(in range: Range<Int>) -> Int {
        if let rng = self.rng {
            return range.lowerBound + rng.nextInt(upperBound: range.upperBound - range.lowerBound);
        }
        else {
            return Int.random(in: range);
        }
    }

    public func next(in range: ClosedRange<Int>) -> Int {
        if let rng = self.rng {
            let lower: Int = range.lowerBound;
            let upper: Int = range.upperBound;
            let span: Int = max(1, (upper == Int.max ? upper - 1 : upper) - lower + 1);
            return range.lowerBound + rng.nextInt(upperBound: span);
        }
        else {
            return Int.random(in: range);
        }
    }

    private static func convertIntToUInt64(_ value: Int) -> UInt64 {
        return (value == Int.min) ? UInt64(Int.max) + 1 : UInt64(abs(value));
    }
}
