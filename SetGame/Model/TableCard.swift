import SwiftUI

/// TableCard represent a SET card on the table.
/// A subclass of Card, it can be in a selected state or not.
///
public class TableCard : Card, ObservableObject {

    private struct Defaults {
        fileprivate static let blinkCount: Int               = 4;
        fileprivate static let blinkInterval: Double         = 0.15;
        fileprivate static let shakeCount: Int               = 9;
        fileprivate static let shakeSpeed: Double            = 0.55;
        fileprivate static let materializeSpeed: Double      = 0.70;
        fileprivate static let materializeElasticity: Double = 0.40;
    }

    @Published var selected: Bool                   = false;
    //
    // These blinking/blinkoff properties are used ONLY for blinking the 3 cards when a
    // SET is found; the blinking property means that we are in the processing of doing
    // the 3-card blinking; the blinkoff property means we are either blinked off (when
    // blinkoff is true) or on (when blinkoff is false) at any one moment; see CardView.
    //
    @Published var blinking: Bool                   = false;
    @Published var blinkoff: Bool                   = false;
               var blinkCount: Int                  = Defaults.blinkCount;
               var blinkInterval: Double            = Defaults.blinkInterval;
               var blinkoffInterval: Double         = 0;
               var blinkDoneCallback: (() -> Void)? = nil;
    @Published var shaking: Bool                    = false;
               var shakeCount: Int                  = Defaults.shakeCount;
               var shakeSpeed: Double               = Defaults.shakeSpeed;
    @Published var materializeTrigger: Int          = 1;
    @Published var materializedOnce: Bool           = false;
               var materializeSpeed: Double         = Defaults.materializeSpeed;
               var materializeElasticity: Double    = Defaults.materializeElasticity;

    required init() {
        super.init(color: .random, shape: .random, filling: .random, number: .random);
    }

    required init?(_ value : String) {
        if let card = Self.from(value) {
            super.init(card);
        }
        else {
            return nil;
        }
    }

    required convenience init?(_ value : Substring) {
        self.init(String(value));
    }

    required init(color: CardColor, shape: CardShape, filling: CardFilling, number: CardNumber) {
        super.init(color: color, shape: shape, filling: filling, number: number);
    }

    required init(_ card : Card) {
        super.init(card);
    }

    convenience init(_ card: TableCard) {
        //
        // FYI no need to copy over the various state variables
        // concerning selection, blinking, shaking, or materializing.
        //
        self.init(color: card.color, shape: card.shape, filling: card.filling, number: card.number)
    }

    override class func from(_ value: String) -> TableCard? {
        if let card = super.from(value) {
            return TableCard(card);
        }
        return nil;
    }

    override func toString(_ verbose : Bool = false) -> String {
        return super.toString(verbose) + ":\(self.selected)";
    }

    public func nonset(on table: Table) -> Bool {
        return table.state.nonset.contains(self.id);
    }

    public func select(_ value: Bool? = nil, toggle: Bool? = nil) {
        if let value = value {
            self.selected = value;
        }
        else if let toggle = toggle {
            if (toggle) {
                self.selected.toggle();
            }
        }
        else {
            self.selected = true;
        }
    }

    private static func delay(delay: Double? = nil, callback: @escaping () -> Void) -> Bool {
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

    public func blink(count: Int = 0,
                      interval: Double = 0, offinterval: Double = 0, delay: Double? = nil,
                    _ blinkDoneCallback: (() -> Void)? = nil) {
        if let delay: Double = delay {
            TableCard.delay(delay: delay) {
                self.blink(count: count, interval: interval, offinterval: offinterval, delay: nil, blinkDoneCallback);
            }
            return;
        }
        self.blinkCount = count > 0 ? count : Defaults.blinkCount;
        self.blinkInterval = interval > 0 ? interval : Defaults.blinkInterval;
        self.blinkoffInterval = offinterval > 0 ? offinterval : self.blinkInterval;
        self.blinkDoneCallback = blinkDoneCallback;
        self.blinking = true;
    }

    public func shake(count: Int = 0, speed: Double = 0, delay: Double? = nil) {
        if let delay: Double = delay {
            TableCard.delay(delay: delay) {
                self.shake(count: count, speed: speed, delay: nil);
            }
            return;
        }
        self.shakeCount = count > 0 ? count : Defaults.shakeCount;
        self.shakeSpeed = speed > 0 ? speed : Defaults.shakeSpeed;
        self.shaking = true;
    }

    public func materialize(once: Bool = false, speed: Double = 0, elasticity: Double = 0, delay: Double? = nil) {
        if let delay: Double = delay {
            TableCard.delay(delay: delay) {
                self.materialize(once: once, speed: speed, elasticity: elasticity, delay: nil);
            }
            return;
        }
        if (once) {
            //
            // IMPORTANT NOTE:
            //
            // Very special case: See CardView.init for where the materialize argument is true.
            // The reason we want to do the materialize differently "once" when used in CardView
            // is because otherwise we would visually see a flash of the full card and then
            // the materialization (fading in) of it; we don't want the flash.
            //
            // And note that this can (should) be reset using the reset method if/when
            // a card is "handed off" from one view to another, e.g. like when moving
            // a card from the main table view to the found-sets view.
            //
            if (!self.materializedOnce) {
                self.materializedOnce = true;
                DispatchQueue.main.async {
                    self.materialize(speed: speed, elasticity: elasticity);
                }
            }
            return;
        }
        self.materializeSpeed = speed > 0 ? speed : Defaults.materializeSpeed;
        self.materializeElasticity = elasticity > 0 ? elasticity : Defaults.materializeElasticity;
        self.materializeTrigger += 1;
    }

    public func reset() {
        self.selected = false;
        self.materializedOnce = false;
    }
}
