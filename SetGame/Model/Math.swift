import Foundation


struct Math {

    public static func combinations(_ n: Int, _ k: Int) -> Int {
        guard n >= 0, k >= 0, k <= n else {
            return 0;
        }
        guard k > 0, k != n else { // if k == 0 || k == n { return 1 }
            return 1;
        }
        let k: Int = min(k, n - k);
        var result: Int = 1;
        for i in 1...k {
            result = result * (n - k + i) / i;
        }
        return result;
    }

    /// Compute "n choose k" as a Double, using a stable multiplicative formula.
    /// N.B. ChatGPT generated.
    ///
    public static func binomial(_ n: Int, _ k: Int) -> Double {
        precondition(n >= 0 && k >= 0 && k <= n, "Invalid n, k for binomial")
        if k == 0 || k == n { return 1.0 }
        let k = min(k, n - k)  // exploit symmetry
        var result = 1.0
        for i in 1...k {
            result *= Double(n - k + i)
            result /= Double(i)
        }
        return result
    }

    public static func power(_ base: Int, _ exponent: Int) -> Int {
        guard exponent > 0 else {
            return 1;
        }
        var result: Int = 1;
        for _ in 0..<exponent {
            result *= base;
        }
        return result;
    }
}
