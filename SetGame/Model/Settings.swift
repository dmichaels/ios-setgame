import Foundation
import SwiftUI

// TODO
// Eventually more Table.Settings here.
//
class Defaults {
    public static let sounds: Bool = true;
    public static let haptics: Bool = true;
}

class Settings: ObservableObject {
    @Published var version: Int = 0;
    @Published var sounds: Bool = Defaults.sounds;
    @Published var haptics: Bool = Defaults.haptics;
}
