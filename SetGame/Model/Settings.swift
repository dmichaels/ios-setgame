import Combine
import Foundation
import SwiftUI

public class Defaults {

    // These settings are persisted across game instances.

    public static let showPartialSetHint: Bool   = true;
    public static let showSetsPresentCount: Bool = true;
    public static let showPeekButton: Bool       = true;
    public static let showTimer: Bool            = false;
    public static let peekDisjoint: Bool         = false;
    public static let additionalCards: Int       = 3;
    public static let plantSet: Bool             = false;
    public static let plantMagicSquare: Bool     = false;
    public static let moveSetFront: Bool         = false;
    public static let showFoundSets: Bool        = true;
    public static let displayCardCount: Int      = 12;
    public static let cardsPerRow: Int           = 4;
    public static let cardsAskew: Bool           = false;
    public static let alternateCards: Int        = 1;
    public static let simpleDeck: Bool           = false;
    public static let sounds: Bool               = false;
    public static let haptics: Bool              = false;
    public static let hideHelpButton: Bool       = false;
    public static let demoMode: Bool             = false;
    public static let debugMode: Bool            = false;

    // These settings are NOT persisted across game instances.

    public static let title: String                     = "Logicard";
    public static let debugView: Bool                   = true;

    public struct Effects {
        public static let selectBeforeSetDelay: Double  = 0.80;
        public static let selectAfterSetDelay: Double   = 0.40;
        public static let blinkCount: Int               = 4;
        public static let blinkInterval: Double         = 0.15;
        public static let flipCount: Int                = 2;
        public static let flipDuration: Double          = 0.4;
        public static let flipLeft: Bool                = false;
        public static let shakeCount: Int               = 11;
        public static let shakeDuration: Double         = 0.90;
        public static let materializeSpeed: Double      = 0.70;
        public static let materializeElasticity: Double = 0.40;
    }
}

public final class Settings: ObservableObject {

    // This business is for the persistence of Settings;
    // with compliments (?) to ChatGPT for help on this.
    // Note that demoMode is intentionally left out.

    private enum Keys {
        static let showPartialSetHint   = "showPartialSetHint"
        static let showSetsPresentCount = "showSetsPresentCount"
        static let showPeekButton       = "showPeekButton"
        static let showTimer            = "showTimer"
        static let peekDisjoint         = "peekDisjoint"
        static let additionalCards      = "additionalCards"
        static let plantSet             = "plantSet"
        static let plantMagicSquare     = "plantMagicSquare"
        static let moveSetFront         = "moveSetFront"
        static let showFoundSets        = "showFoundSets"
        static let displayCardCount     = "displayCardCount"
        static let cardsPerRow          = "cardsPerRow"
        static let cardsAskew           = "cardsAskew"
        static let alternateCards       = "alternateCards"
        static let simpleDeck           = "simpleDeck"
        static let sounds               = "sounds"
        static let haptics              = "haptics"
        static let hideHelpButton       = "hideHelpButton"
        static let debugMode            = "debugMode"
    }

    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    init() {

        showPartialSetHint   = defaults.object(forKey: Keys.showPartialSetHint)   as? Bool ?? Defaults.showPartialSetHint
        showSetsPresentCount = defaults.object(forKey: Keys.showSetsPresentCount) as? Bool ?? Defaults.showSetsPresentCount
        showPeekButton       = defaults.object(forKey: Keys.showPeekButton)       as? Bool ?? Defaults.showPeekButton
        showTimer            = defaults.object(forKey: Keys.showTimer)            as? Bool ?? Defaults.showTimer
        peekDisjoint         = defaults.object(forKey: Keys.peekDisjoint)         as? Bool ?? Defaults.peekDisjoint
        additionalCards      = defaults.object(forKey: Keys.additionalCards)      as? Int  ?? Defaults.additionalCards
        plantSet             = defaults.object(forKey: Keys.plantSet)             as? Bool ?? Defaults.plantSet
        plantMagicSquare     = defaults.object(forKey: Keys.plantMagicSquare)     as? Bool ?? Defaults.plantMagicSquare
        moveSetFront         = defaults.object(forKey: Keys.moveSetFront)         as? Bool ?? Defaults.moveSetFront
        showFoundSets        = defaults.object(forKey: Keys.showFoundSets)        as? Bool ?? Defaults.showFoundSets
        displayCardCount     = defaults.object(forKey: Keys.displayCardCount)     as? Int  ?? Defaults.displayCardCount
        cardsPerRow          = defaults.object(forKey: Keys.cardsPerRow)          as? Int  ?? Defaults.cardsPerRow
        cardsAskew           = defaults.object(forKey: Keys.cardsAskew)           as? Bool ?? Defaults.cardsAskew
        alternateCards       = defaults.object(forKey: Keys.alternateCards)       as? Int  ?? Defaults.alternateCards
        simpleDeck           = defaults.object(forKey: Keys.simpleDeck)           as? Bool ?? Defaults.simpleDeck
        sounds               = defaults.object(forKey: Keys.sounds)               as? Bool ?? Defaults.sounds
        haptics              = defaults.object(forKey: Keys.haptics)              as? Bool ?? Defaults.haptics
        hideHelpButton       = defaults.object(forKey: Keys.hideHelpButton)       as? Bool ?? Defaults.hideHelpButton
        debugMode            = defaults.object(forKey: Keys.debugMode)            as? Bool ?? Defaults.debugMode

        $showPartialSetHint
            .sink { self.defaults.set($0, forKey: Keys.showPartialSetHint) }
            .store(in: &cancellables)
        $showSetsPresentCount
            .sink { self.defaults.set($0, forKey: Keys.showSetsPresentCount) }
            .store(in: &cancellables)
        $showPeekButton
            .sink { self.defaults.set($0, forKey: Keys.showPeekButton) }
            .store(in: &cancellables)
        $showTimer
            .sink { self.defaults.set($0, forKey: Keys.showTimer) }
            .store(in: &cancellables)
        $peekDisjoint
            .sink { self.defaults.set($0, forKey: Keys.peekDisjoint) }
            .store(in: &cancellables)
        $additionalCards
            .sink { self.defaults.set($0, forKey: Keys.additionalCards) }
            .store(in: &cancellables)
        $plantSet
            .sink { self.defaults.set($0, forKey: Keys.plantSet) }
            .store(in: &cancellables)
        $plantMagicSquare
            .sink { self.defaults.set($0, forKey: Keys.plantMagicSquare) }
            .store(in: &cancellables)
        $moveSetFront
            .sink { self.defaults.set($0, forKey: Keys.moveSetFront) }
            .store(in: &cancellables)
        $showFoundSets
            .sink { self.defaults.set($0, forKey: Keys.showFoundSets) }
            .store(in: &cancellables)
        $displayCardCount
            .sink { self.defaults.set($0, forKey: Keys.displayCardCount) }
            .store(in: &cancellables)
        $cardsPerRow
            .sink { self.defaults.set($0, forKey: Keys.cardsPerRow) }
            .store(in: &cancellables)
        $cardsAskew
            .sink { self.defaults.set($0, forKey: Keys.cardsAskew) }
            .store(in: &cancellables)
        $alternateCards
            .sink { self.defaults.set($0, forKey: Keys.alternateCards) }
            .store(in: &cancellables)
        $simpleDeck
            .sink { self.defaults.set($0, forKey: Keys.simpleDeck) }
            .store(in: &cancellables)
        $sounds
            .sink { self.defaults.set($0, forKey: Keys.sounds) }
            .store(in: &cancellables)
        $haptics
            .sink { self.defaults.set($0, forKey: Keys.haptics) }
            .store(in: &cancellables)
        $hideHelpButton
            .sink { self.defaults.set($0, forKey: Keys.hideHelpButton) }
            .store(in: &cancellables)
        $debugMode
            .sink { self.defaults.set($0, forKey: Keys.debugMode) }
            .store(in: &cancellables)
    }

    public func reset() {

        // Called from SettingsView to reset to original ("factory") settings.

        defaults.removeObject(forKey: Keys.showPartialSetHint)
        defaults.removeObject(forKey: Keys.showSetsPresentCount)
        defaults.removeObject(forKey: Keys.showPeekButton)
        defaults.removeObject(forKey: Keys.showTimer)
        defaults.removeObject(forKey: Keys.peekDisjoint)
        defaults.removeObject(forKey: Keys.additionalCards)
        defaults.removeObject(forKey: Keys.plantSet)
        defaults.removeObject(forKey: Keys.plantMagicSquare)
        defaults.removeObject(forKey: Keys.moveSetFront)
        defaults.removeObject(forKey: Keys.showFoundSets)
        defaults.removeObject(forKey: Keys.displayCardCount)
        defaults.removeObject(forKey: Keys.cardsPerRow)
        defaults.removeObject(forKey: Keys.cardsAskew)
        defaults.removeObject(forKey: Keys.alternateCards)
        defaults.removeObject(forKey: Keys.simpleDeck)
        defaults.removeObject(forKey: Keys.sounds)
        defaults.removeObject(forKey: Keys.haptics)
        defaults.removeObject(forKey: Keys.hideHelpButton)
        defaults.removeObject(forKey: Keys.debugMode)

        showPartialSetHint   = Defaults.showPartialSetHint
        showSetsPresentCount = Defaults.showSetsPresentCount
        showPeekButton       = Defaults.showPeekButton
        showTimer            = Defaults.showTimer
        peekDisjoint         = Defaults.peekDisjoint
        additionalCards      = Defaults.additionalCards
        plantSet             = Defaults.plantSet
        plantMagicSquare     = Defaults.plantMagicSquare
        moveSetFront         = Defaults.moveSetFront
        showFoundSets        = Defaults.showFoundSets
        displayCardCount     = Defaults.displayCardCount
        cardsPerRow          = Defaults.cardsPerRow
        cardsAskew           = Defaults.cardsAskew
        alternateCards       = Defaults.alternateCards
        simpleDeck           = Defaults.simpleDeck
        sounds               = Defaults.sounds
        haptics              = Defaults.haptics
        hideHelpButton       = Defaults.hideHelpButton
        debugMode            = Defaults.debugMode
    }

    public func isDefault() -> Bool {

        // Called from SettingsView to disable the button
        // to reset to original ("factory") settings.

        return ((showPartialSetHint   == Defaults.showPartialSetHint)
            &&  (showSetsPresentCount == Defaults.showSetsPresentCount)
            &&  (showPeekButton       == Defaults.showPeekButton)
            &&  (showTimer            == Defaults.showTimer)
            &&  (peekDisjoint         == Defaults.peekDisjoint)
            &&  (additionalCards      == Defaults.additionalCards)
            &&  (plantSet             == Defaults.plantSet)
            &&  (plantMagicSquare     == Defaults.plantMagicSquare)
            &&  (moveSetFront         == Defaults.moveSetFront)
            &&  (showFoundSets        == Defaults.showFoundSets)
            &&  (displayCardCount     == Defaults.displayCardCount)
            &&  (cardsPerRow          == Defaults.cardsPerRow
            &&  (cardsAskew           == Defaults.cardsAskew))
            &&  (alternateCards       == Defaults.alternateCards)
            &&  (simpleDeck           == Defaults.simpleDeck)
            &&  (sounds               == Defaults.sounds)
            &&  (haptics              == Defaults.haptics)
            &&  (hideHelpButton       == Defaults.hideHelpButton)
            &&  (debugMode            == Defaults.debugMode)
        )
    }

    // These are the actual app settings properties.

    @Published var showPartialSetHint: Bool   = Defaults.showPartialSetHint;
    @Published var showSetsPresentCount: Bool = Defaults.showSetsPresentCount;
    @Published var showPeekButton: Bool       = Defaults.showPeekButton;
    @Published var showTimer: Bool            = Defaults.showTimer;
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
    @Published var hideHelpButton: Bool       = Defaults.hideHelpButton;
    @Published var debugMode: Bool            = Defaults.debugMode;
    @Published var demoMode: Bool             = Defaults.demoMode;
}
