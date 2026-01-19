import Foundation
import SwiftUI

public func Delay(delay: Double? = nil, callback: @escaping () -> Void) -> Bool {
    if let delay: Double = delay {
        if (delay > 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { callback(); }
        }
        else {
            DispatchQueue.main.async { callback(); }
        }
        return true;
    }
    return false;
}
