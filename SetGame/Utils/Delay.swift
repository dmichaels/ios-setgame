import Foundation

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
