import SwiftUI

/// TableCard represent a SET card on the table.
/// A subclass of Card, it can be in a selected state or not.
///
public class TableCard : Card, ObservableObject {

    private struct Defaults {
        fileprivate static let blinkCount: Int               = 4;
        fileprivate static let blinkInterval: Double         = 0.15;
        fileprivate static let flipCount: Int                = 2;
        fileprivate static let flipDuration: Double          = 0.4;
        fileprivate static let flipLeft: Bool                = false;
        fileprivate static let shakeCount: Int               = 11;
        fileprivate static let shakeDuration: Double         = 0.90;
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
    @Published var flipTrigger: Int                 = 0;
               var flipCount: Int                   = Defaults.flipCount;
               var flipDuration: Double             = Defaults.flipDuration;
               var flipLeft: Bool                   = Defaults.flipLeft;
    @Published var shakeTrigger: Int                = 0;
               var shakeCount: Int                  = Defaults.shakeCount;
               var shakeDuration: Double               = Defaults.shakeDuration;
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

    public static func delay(delay: Double? = nil, callback: @escaping () -> Void) -> Bool {
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

    public func select(_ value: Bool? = nil, toggle: Bool? = nil, delay: Double? = nil) {
        if let delay: Double = delay {
            Delay(by: delay) {
                self.select(value, toggle: toggle, delay: nil);
            }
            return;
        }
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

    public func blink(count: Int = 0,
                      interval: Double = 0, offinterval: Double = 0, delay: Double? = nil,
                    _ blinkDoneCallback: (() -> Void)? = nil) {
        if let delay: Double = delay {
            Delay(by: delay) {
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

    public func flip(count: Int = 0, duration: Double = 0, left: Bool = false, delay: Double? = nil) {
        if let delay: Double = delay {
            Delay(by: delay) {
                self.flip(count: count, duration: duration, left: left, delay: nil);
            }
            return;
        }
        self.flipCount = count > 0 ? count : Defaults.flipCount;
        self.flipDuration = duration > 0 ? duration : Defaults.flipDuration;
        self.flipLeft = left;
        self.flipTrigger += 1;
    }

    public func shake(count: Int = 0, duration: Double = 0, delay: Double? = nil) {
        if let delay: Double = delay {
            Delay(by: delay) {
                self.shake(count: count, duration: duration, delay: nil);
            }
            return;
        }
        self.shakeCount = count > 0 ? count : Defaults.shakeCount;
        self.shakeDuration = duration > 0 ? duration : Defaults.shakeDuration;
        self.shakeTrigger += 1;
    }

    public func materialize(once: Bool = false, speed: Double = 0, elasticity: Double = 0, delay: Double? = nil) {
        if let delay: Double = delay {
            Delay(by: delay) {
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
