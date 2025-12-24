import SwiftUI

struct StatusBarView: View {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;

    let OK_SYMBOL           : String = "\u{1F44C}";
    let THUMBSUP_SYMBOL     : String = "\u{1F44D}";
    let NEUTRAL_FACE_SYMBOL : String = "\u{1F610}";
    let HAPPY_FACE_SYMBOL   : String = "\u{1F642}";
    let SAD_FACE_SYMBOL     : String = "\u{1F641}";
    let DIAMOND_SYMBOL      : String = "\u{2756}";
    let CHECK_MARK_SYMBOL   : String = "✅";

    // let FOREGROUND: Color = Color(red: 0.3, green: 0.4, blue: 0.4);
    // let BACKGROUND: Color = Color(red: 0.7, green: 0.8, blue: 0.9)
    // let BACKGROUND: Color = Color(hex: 0xCFDEFF);
    // let FOREGROUND: Color = Color(hex: 0x225066);
    // let FOREGROUND: Color = Color(hex: 0x404252);
    // let FOREGROUND: Color = Color(hex: 0x738375);
    let FOREGROUND: Color = Color(hex: 0x283028);
    // let BACKGROUND: Color = Color(hex: 0xEDFDEF);
    // let BACKGROUND: Color = Color(hex: 0xC4D8FF);
    let BACKGROUND: Color = Color(hex: 0xD5E9FF);
    let SHAPE = RoundedRectangle(cornerRadius: 11, style: .continuous);

    // func partialSetSelectedOne() -> Bool { self.table.state.partialSetSelected && table.cards.count == 1; }
    // func partialSetSelectedTwo() -> Bool { self.table.state.partialSetSelected && table.cards.count == 2; }
    private func gameDone() -> Bool { (self.table.deck.count == 0) && !self.table.containsSet(); }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("  SETs: \(table.state.setsFoundCount)")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(alignment: .leading)
                .foregroundColor(FOREGROUND)
            if (self.gameDone()) {
                Text(CHECK_MARK_SYMBOL)
                    .font(.subheadline)
                    .frame(alignment: .leading)
            }
            else {
                Text("\(DIAMOND_SYMBOL)  Deck: \(table.remainingCardCount())")
                    .font(.subheadline)
                    .frame(alignment: .leading)
                    .foregroundColor(FOREGROUND)
            }
            Spacer()
                if (self.table.settings.showPartialSetSelectedIndicator) {
                    if (self.table.state.blinking || self.table.selectedCards().isSet()) {
                            Text(HAPPY_FACE_SYMBOL)
                                .scaleEffect(1.2)
                                .font(.subheadline)
                                .foregroundColor(FOREGROUND)
                                .padding(.trailing, self.table.settings.showNumberOfSetsPresent || settings.showPeekButton ? 4 : 10)
                    }
                    else if (self.table.state.partialSetSelected) {
                        if (self.table.selectedCardCount() == 1) {
                            Text(OK_SYMBOL)
                                .scaleEffect(1.2)
                                .font(.subheadline)
                                .foregroundColor(FOREGROUND)
                                .padding(.trailing, self.table.settings.showNumberOfSetsPresent || settings.showPeekButton ? 4 : 10)
                        }
                        else if (self.table.selectedCardCount() == 2) {
                            Text(THUMBSUP_SYMBOL)
                                .scaleEffect(1.2)
                                .font(.subheadline)
                                .foregroundColor(FOREGROUND)
                                .padding(.trailing, self.table.settings.showNumberOfSetsPresent || settings.showPeekButton ? 4 : 10)
                        }
                        else {
                            Text(NEUTRAL_FACE_SYMBOL)
                                .scaleEffect(1.2)
                                .font(.subheadline)
                                .foregroundColor(FOREGROUND)
                                .padding(.trailing, self.table.settings.showNumberOfSetsPresent || settings.showPeekButton ? 4 : 10)
                        }
                    }
                    else if ((self.table.selectedCardCount() == 1) || (self.table.selectedCardCount() == 2)) {
                        Text(SAD_FACE_SYMBOL)
                            .scaleEffect(1.2)
                            .font(.subheadline)
                            .padding(.trailing, self.table.settings.showNumberOfSetsPresent || settings.showPeekButton ? 4 : 10)
                    }
                    else if (self.table.state.setJustFound || self.table.selectedCards().isSet()) {
                        Text(HAPPY_FACE_SYMBOL)
                            .scaleEffect(1.2)
                            .font(.subheadline)
                            .padding(.trailing, self.table.settings.showNumberOfSetsPresent || settings.showPeekButton ? 4 : 10)
                    }
                    else if (self.table.state.setJustFoundNot) {
                        Text(SAD_FACE_SYMBOL)
                            .scaleEffect(1.2)
                            .font(.subheadline)
                            .padding(.trailing, self.table.settings.showNumberOfSetsPresent || settings.showPeekButton ? 4 : 10)
                    }
                    else {
                        Text(NEUTRAL_FACE_SYMBOL)
                            .scaleEffect(1.2)
                            .font(.subheadline)
                            .frame(alignment: .leading)
                            .padding(.trailing, self.table.settings.showNumberOfSetsPresent || settings.showPeekButton ? 4 : 10)
                    }
                }
            if (self.table.settings.showNumberOfSetsPresent) {
                Text("\(table.numberOfSets())")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundColor(FOREGROUND)
                    .fixedSize()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1.0)
                    .offset(y: 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(FOREGROUND, lineWidth: 1)
                    )
                    .padding(.trailing, settings.showPeekButton ? 3 : 10)
                }
            if (settings.showPeekButton) {
                Button(action: {
                    self.table.state.showingOneRandomSet.toggle();
                    if (self.table.state.showingOneRandomSet) {
                        self.table.selectOneRandomSet();
                    }
                    else {
                        self.table.unselectCards();
                    }
                }) {
                    Image(systemName: "eyes")
                        .foregroundColor(self.table.containsSet() ? FOREGROUND : Color.gray)
                        .scaleEffect(1.05)
                        .padding(.trailing, 8)
                        .offset(y: 0.5)
                }
            }
        }
        .background(
            //
            // The corner-radius controls how rounded the control window corners are;
            // greater is more rounded.
            //
            SHAPE // RoundedRectangle(cornerRadius: 10, style: .continuous)
                //
                // This fill-thin-material makes the control background blend in with what is behind it.
                //
                // .fill(.white)
                // .fill(Color(UIColor.systemGray4))
                .fill(BACKGROUND)
                // .fill(.thinMaterial)
                //
                // This opacity controls how transparent the (background of) the control is.
                //
                .opacity(0.8)
                //
                // This frame-height controls the height of the control; default without this is fairly short.
                //
                .frame(height: 35)
                //
                // This padding-horizontal controls the internal left/right padding of control as a whole.
                //
                // .padding(.horizontal, 0)
                //
                // This shadow-radius controls the soft drop shadow around/behind the control.
                // though can't really see a different with it on/off or high/low.
                //
                // .shadow(radius: 1)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 3, y: 6)
        )
        .background(BACKGROUND)
        .allowsHitTesting(!self.table.state.blinking && !self.table.settings.demoMode)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255
        )
    }
}
