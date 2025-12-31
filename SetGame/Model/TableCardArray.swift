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
            card.blinkout = false; // just in case
        }
    }

    func blinkoutToggle()
    {
        for card in self {
            card.blinkout.toggle();
        }
    }
}
