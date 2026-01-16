extension Array where Element : TableCard
{
    var blinking: Bool
    {
        for card in self {
            if (card.blinking) {
                return true;
            }
        }
        return false;
    }

    func blinkingStart() {
        for card in self {
            card.blinking = true;
        }
    }

    func blinkingEnd() {
        for card in self {
            card.blinking = false;
            card.blinkoff = false; // just in case
        }
    }

    func blinkoffToggle()
    {
        for card in self {
            card.blinkoff.toggle();
        }
    }

    func select(_ value: Bool? = nil, toggle: Bool? = nil) {
        for card in self {
            card.select(value, toggle: toggle);
        }
    }

    func blink(count: Int = 0,
               interval: Double = 0, offinterval: Double = 0.0, delay: Double = 0,
             _ blinkDoneCallback: (() -> Void)? = nil)  {
        let ncards: Int = self.count;
        var ndone: Int = 0;
        func blinkDone() {
            ndone += 1;
            if (ndone == ncards) {
                blinkDoneCallback?();
            }
        }
        for card in self {
            card.blink(count: count, interval: interval, offinterval: offinterval, delay: delay, blinkDone);
        }
    }

    func shake(count: Int = 0, speed: Double = 0, delay: Double = 0) {
        for card in self {
            card.shake(count: count, speed: speed, delay: delay);
        }
    }

    func materialize(once: Bool = false, speed: Double = 0, elasticity: Double = 0, delay: Double = 0) {
        for card in self {
            card.materialize(once: once, speed: speed, elasticity: elasticity, delay: delay);
        }
    }
}
