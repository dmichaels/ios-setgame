import SwiftUI

/// TableCard represent a SET card on the table.
/// A subclass of Card, it can be in a selected state or not.
///
class TableCard : Card, ObservableObject {

    private struct Defaults {
        fileprivate static let blinkCount: Int               = 3;
        fileprivate static let blinkInterval: Double         = 0.12;
        fileprivate static let shakeCount: Int               = 9;
        fileprivate static let shakeSpeed: Double            = 0.55;
        fileprivate static let materializeSpeed: Double      = 0.70;
        fileprivate static let materializeElasticity: Double = 0.40;
    }

    @Published var set: Bool                     = false;
    @Published var selected: Bool                = false;
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
    @Published var materializeNonce: Int            = 1;
    @Published var materializedInit: Bool           = false;
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
        self.init(card);
        self.set = card.set;
        self.selected = card.selected;
        self.blinking = card.blinking;
        self.blinkoff = card.blinkoff;
        self.blinkCount = card.blinkCount;
        self.blinkInterval = card.blinkInterval;
        self.blinkoffInterval = card.blinkoffInterval;
        self.blinkDoneCallback = card.blinkDoneCallback;
        self.shaking = card.shaking;
        self.shakeCount = card.shakeCount;
        self.shakeSpeed = card.shakeSpeed;
        self.materializeNonce = card.materializeNonce;
        self.materializedInit = card.materializedInit;
        self.materializeSpeed = card.materializeSpeed;
        self.materializeElasticity = card.materializeElasticity;
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

    public func newcomer(to table: Table<TableCard>) -> Bool {
        return table.state.newcomers.contains(self.id);
    }

    public func nonset(on table: Table<TableCard>) -> Bool {
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

    public func blink(count: Int = 0,
                      interval: Double = 0, _ intervalOff: Double = 0,
                    _ blinkDoneCallback: (() -> Void)? = nil) {
        self.blinkCount = count > 0 ? count : Defaults.blinkCount;
        self.blinkInterval = interval > 0 ? interval : Defaults.blinkInterval;
        self.blinkoffInterval = intervalOff > 0 ? intervalOff : self.blinkInterval;
        self.blinkDoneCallback = blinkDoneCallback;
        self.blinking = true;
    }

    public func shake(count: Int = 0, speed: Double = 0) {
        self.shakeCount = count > 0 ? count : Defaults.shakeCount;
        self.shakeSpeed = speed > 0 ? speed : Defaults.shakeSpeed;
        self.shaking = true;
    }

    public func materialize(speed: Double = 0, elasticity: Double = 0) {
        self.materializeSpeed = speed > 0 ? speed : Defaults.materializeSpeed;
        self.materializeElasticity = elasticity > 0 ? elasticity : Defaults.materializeElasticity;
        self.materializeNonce += 1;
    }
}
