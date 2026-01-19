public extension Array where Element : TableCard
{
    func select(_ value: Bool? = nil, toggle: Bool? = nil, delay: Double? = nil) {
        for card in self {
            card.select(value, toggle: toggle, delay: delay);
        }
    }

    func blink(count: Int = 0,
               interval: Double = 0, offinterval: Double = 0.0, delay: Double? = nil,
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

    func flip(count: Int = 0, duration: Double = 0, left: Bool = false, delay: Double? = nil) {
        for card in self {
            card.flip(count: count, duration: duration, left: left, delay: delay);
        }
    }

    func shake(count: Int = 0, duration: Double = 0, delay: Double? = nil) {
        for card in self {
            card.shake(count: count, duration: duration, delay: delay);
        }
    }

    func materialize(once: Bool = false, speed: Double = 0, elasticity: Double = 0, delay: Double? = nil) {
        for card in self {
            card.materialize(once: once, speed: speed, elasticity: elasticity, delay: delay);
        }
    }

    func reset() {
        for card in self {
            card.reset();
        }
    }
}
