import Foundation
import SwiftUI

// TODO
// Eventually more Table.Settings here.
//
class Defaults {
    public static let showPartialSetHint: Bool   = true;
    public static let showSetsPresentCount: Bool = true;
    public static let showPeekButton: Bool       = true;
    public static let peekDisjoint: Bool         = false;
    public static let moreCardsIfNoSet: Bool     = true;
    public static let plantSet: Bool             = false;
    public static let plantMagicSquare: Bool     = false;
    public static let moveSetFront: Bool         = false;
    public static let showFoundSets: Bool        = true;
    public static let displayCardCount: Int      = 12;
    public static let cardsPerRow: Int           = 4;
    public static let cardsAskew: Bool           = false;
    public static let alternateCards: Bool       = true;
    public static let simpleDeck: Bool           = false;
    public static let sounds: Bool               = false;
    public static let haptics: Bool              = false;
    public static let demoMode: Bool             = false;
}

class Settings: ObservableObject {
    @Published var showPeekButton: Bool = Defaults.showPeekButton;
    @Published var peekDisjoint: Bool   = Defaults.peekDisjoint;
    @Published var sounds: Bool         = Defaults.sounds;
    @Published var haptics: Bool        = Defaults.haptics;
    @Published var version: Int         = 0;
}

class XSettings: ObservableObject {
    public static let showPartialSetHint: Bool   = Defaults.showPartialSetHint;
    public static let showSetsPresentCount: Bool = Defaults.showSetsPresentCount;
    public static let showPeekButton: Bool       = Defaults.showPeekButton;
    public static let peekDisjoint: Bool         = Defaults.peekDisjoint;
    public static let moreCardsIfNoSet: Bool     = Defaults.moreCardsIfNoSet;
    public static let plantSet: Bool             = Defaults.plantSet;
    public static let plantMagicSquare: Bool     = Defaults.plantMagicSquare;
    public static let moveSetFront: Bool         = Defaults.moveSetFront;
    public static let showFoundSets: Bool        = Defaults.showFoundSets;
    public static let displayCardCount: Int      = Defaults.displayCardCount;
    public static let cardsPerRow: Int           = Defaults.cardsPerRow;
    public static let cardsAskew: Bool           = Defaults.cardsAskew;
    public static let alternateCards: Bool       = Defaults.alternateCards;
    public static let simpleDeck: Bool           = Defaults.simpleDeck;
    public static let sounds: Bool               = Defaults.sounds;
    public static let haptics: Bool              = Defaults.haptics;
    public static let demoMode: Bool             = Defaults.demoMode;
}
