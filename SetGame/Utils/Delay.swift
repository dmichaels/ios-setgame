import Foundation

public struct DelayBy: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    private let c: Double;
    private let r: ClosedRange<Double>?;
    public init(_ value: Int) { c = Double(value); r = nil; }
    public init(integerLiteral value: Int) { c = Double(value); r = nil; }
    public init(_ value: Double) { c = Double(value); r = nil; }
    public init(floatLiteral value: Double) { c = Double(value); r = nil; }
    public init(_ r: ClosedRange<Double>) { c = 0; self.r = r; }
    public init(_ r: ClosedRange<Int>) { self.init(Double(r.lowerBound)...Double(r.upperBound)); }
    public var value: Double {
        if let r: ClosedRange<Double> = r {
            return Double.random(in: r);
        }
        else {
            return c;
        }
    }
}

public func Delay(by delay: DelayBy?, callback: @escaping () -> Void) {
    Delay(by: delay?.value, callback: callback);
}

public func Delay(by delay: Double? = nil, callback: @escaping () -> Void) {
    if let delay: Double = delay {
        if (delay > 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { callback(); }
        }
        else {
            DispatchQueue.main.async { callback(); }
        }
    }
    else {
        callback();
    }
}
