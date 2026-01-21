import SwiftUI

/// TableCard represent a SET card on the table.
/// A subclass of Card, it can be in a selected state or not.
///
public class TableCard : Card, ObservableObject {

    @Published var selected: Bool                   = false;
    @Published var blinkTrigger: Int                = 0;
               var blinkCount: Int                  = Defaults.Effects.blinkCount;
               var blinkInterval: Double            = Defaults.Effects.blinkInterval;
               var blinkoffInterval: Double         = 0;
               var blinkDoneCallback: (() -> Void)? = nil;
    @Published var flipTrigger: Int                 = 0;
               var flipCount: Int                   = Defaults.Effects.flipCount;
               var flipDuration: Double             = Defaults.Effects.flipDuration;
               var flipLeft: Bool                   = Defaults.Effects.flipLeft;
    @Published var shakeTrigger: Int                = 0;
               var shakeCount: Int                  = Defaults.Effects.shakeCount;
               var shakeDuration: Double            = Defaults.Effects.shakeDuration;
    @Published var materializeTrigger: Int          = 1;
    @Published var materializedOnce: Bool           = false;
               var materializeSpeed: Double         = Defaults.Effects.materializeSpeed;
               var materializeElasticity: Double    = Defaults.Effects.materializeElasticity;

    required init() {
        super.init(color: .random, shape: .random, filling: .random, number: .random);
    }

    required init(color: CardColor, shape: CardShape, filling: CardFilling, number: CardNumber) {
        super.init(color: color, shape: shape, filling: filling, number: number);
    }

    required init(_ card : Card) {
        super.init(card);
    }

    override func toString(_ verbose : Bool = false) -> String {
        return super.toString(verbose) + ":\(self.selected)";
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
                self.blink(count: count, interval: interval, offinterval: offinterval,
                           delay: nil, blinkDoneCallback);
            }
            return;
        }
        self.blinkCount = count > 0 ? count : Defaults.Effects.blinkCount;
        self.blinkInterval = interval > 0 ? interval : Defaults.Effects.blinkInterval;
        self.blinkoffInterval = offinterval > 0 ? offinterval : self.blinkInterval;
        self.blinkDoneCallback = blinkDoneCallback;
        self.blinkTrigger += 1;
    }

    public func flip(count: Int = 0, duration: Double = 0, left: Bool = false, delay: Double? = nil) {
        if let delay: Double = delay {
            Delay(by: delay) {
                self.flip(count: count, duration: duration, left: left, delay: nil);
            }
            return;
        }
        self.flipCount = count > 0 ? count : Defaults.Effects.flipCount;
        self.flipDuration = duration > 0 ? duration : Defaults.Effects.flipDuration;
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
        self.shakeCount = count > 0 ? count : Defaults.Effects.shakeCount;
        self.shakeDuration = duration > 0 ? duration : Defaults.Effects.shakeDuration;
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
        self.materializeSpeed = speed > 0 ? speed : Defaults.Effects.materializeSpeed;
        self.materializeElasticity = elasticity > 0 ? elasticity : Defaults.Effects.materializeElasticity;
        self.materializeTrigger += 1;
    }

    public func reset() {
        self.selected = false;
        self.blinkTrigger = 0;
        self.blinkCount = 0;
        self.blinkInterval = 0;
        self.blinkoffInterval = 0;
        self.blinkDoneCallback = nil;
        self.flipTrigger = 0;
        self.flipCount = 0;
        self.flipDuration = 0;
        self.flipLeft = false;
        self.shakeTrigger = 0;
        self.shakeCount = 0;
        self.shakeDuration = 0;
        self.materializeTrigger = 0;
        self.materializedOnce = false;
        self.materializeSpeed = 0;
        self.materializeElasticity = 0;
    }
}
