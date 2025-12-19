import Foundation
import SwiftUI

// TODO
// Eventually more Table.Settings here.
//
class Defaults {
    public static let sounds: Bool = false;
    public static let haptics: Bool = false;
}

class Settings: ObservableObject {
    @Published var version: Int = 0;
    @Published var sounds: Bool = Defaults.sounds;
    @Published var haptics: Bool = Defaults.haptics;
}
