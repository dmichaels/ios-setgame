import Foundation
import SwiftUI

// TODO
// Eventually more Table.Settings here.
//
class Defaults {
    public static let displayCardCount: Int = 12;
    public static let showPeekButton: Bool  = true;
    public static let sounds: Bool          = false;
    public static let haptics: Bool         = false;
}

class Settings: ObservableObject {
    @Published var showPeekButton: Bool = Defaults.showPeekButton;
    @Published var sounds: Bool = Defaults.sounds;
    @Published var haptics: Bool = Defaults.haptics;
    @Published var version: Int = 0;
}
