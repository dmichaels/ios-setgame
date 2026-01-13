import SwiftUI

/// TableCard represent a SET card on the table.
/// A subclass of Card, it can be in a selected state or not.
///
class TableCard : Card, ObservableObject {

    @Published var selected: Bool = false;
    @Published var set: Bool      = false;
    @Published var new: Bool      = false; // xyzzy/experiment
    //
    // These blinking/blinkoff properties are used ONLY for blinking the 3 cards when a
    // SET is found; the blinking property means that we are in the processing of doing
    // the 3-card blinking; the blinkoff property means we are either blinked off (when
    // blinkoff is true) or on (when blinkoff is false) at any one moment; see CardView.
    //
    private struct Defaults {
        fileprivate static let blinkCount: Int = 3;
        fileprivate static let blinkInterval: Double = 0.12;
        fileprivate static let blinkoffInterval: Double = 0.12;
    }
    @Published var blinking: Bool                   = false;
    @Published var blinkoff: Bool                   = false;
               var blinkCount: Int                  = Defaults.blinkCount;
               var blinkInterval: Double            = Defaults.blinkInterval;
               var blinkoffInterval: Double         = Defaults.blinkoffInterval;
               var blinkDoneCallback: (() -> Void)? = nil;

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

    public func fadein() {
        self.new = true;
    }

    public func blink(count: Int = 0, interval: Double = 0.2, _ intervalOff: Double = 0.0, _ blinkDoneCallback: (() -> Void)? = nil) {
        self.blinkCount = count > 0 ? count : Defaults.blinkCount;
        self.blinkInterval = interval > 0.0 ? interval : Defaults.blinkInterval;
        self.blinkoffInterval = intervalOff > 0.0 ? intervalOff : self.blinkInterval;
        self.blinkDoneCallback = blinkDoneCallback;
        self.blinking = true;
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
}
