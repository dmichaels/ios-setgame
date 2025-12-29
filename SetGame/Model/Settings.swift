import Foundation
import SwiftUI

// TODO
// Eventually more Table.Settings here.
//
class Defaults
{
    public static let showPartialSetHint: Bool   = true;
    public static let showSetsPresentCount: Bool = true;
    public static let showPeekButton: Bool       = true;
    public static let peekDisjoint: Bool         = false;
    public static let additionalCards: Int       = 3;
    public static let plantSet: Bool             = false;
    public static let plantMagicSquare: Bool     = false;
    public static let moveSetFront: Bool         = false;
    public static let showFoundSets: Bool        = true;
    public static let displayCardCount: Int      = 12;
    public static let cardsPerRow: Int           = 4;
    public static let cardsAskew: Bool           = false;
    public static let alternateCards: Int        = 2;
    public static let simpleDeck: Bool           = false;
    public static let sounds: Bool               = false;
    public static let haptics: Bool              = false;
    public static let demoMode: Bool             = false;
}

class Settings: ObservableObject
{
    @Published var showPeekButton: Bool = Defaults.showPeekButton;
    @Published var peekDisjoint: Bool   = Defaults.peekDisjoint;
    @Published var sounds: Bool         = Defaults.sounds;
    @Published var haptics: Bool        = Defaults.haptics;
    @Published var version: Int         = 0;
}

class XSettings: ObservableObject
{
    @Published var showPartialSetHint: Bool   = Defaults.showPartialSetHint;
    @Published var showSetsPresentCount: Bool = Defaults.showSetsPresentCount;
    @Published var showPeekButton: Bool       = Defaults.showPeekButton;
    @Published var peekDisjoint: Bool         = Defaults.peekDisjoint;
    @Published var additionalCards: Int       = Defaults.additionalCards;
    @Published var plantSet: Bool             = Defaults.plantSet;
    @Published var plantMagicSquare: Bool     = Defaults.plantMagicSquare;
    @Published var moveSetFront: Bool         = Defaults.moveSetFront;
    @Published var showFoundSets: Bool        = Defaults.showFoundSets;
    @Published var displayCardCount: Int      = Defaults.displayCardCount;
    @Published var cardsPerRow: Int           = Defaults.cardsPerRow;
    @Published var cardsAskew: Bool           = Defaults.cardsAskew;
    @Published var alternateCards: Int        = Defaults.alternateCards;
    @Published var simpleDeck: Bool           = Defaults.simpleDeck;
    @Published var sounds: Bool               = Defaults.sounds;
    @Published var haptics: Bool              = Defaults.haptics;
    @Published var demoMode: Bool             = Defaults.demoMode;
}
