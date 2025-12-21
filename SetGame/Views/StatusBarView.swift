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
    let BACKGROUND: Color = Color(hex: 0xEDFDEF);
    let SHAPE = RoundedRectangle(cornerRadius: 10, style: .continuous);

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
                if (self.table.settings.showNumberOfSetsPresent) {
                    Text("\(DIAMOND_SYMBOL) \(table.numberOfSets())")
                        .font(.subheadline)
                        .frame(alignment: .leading)
                        .foregroundColor(FOREGROUND)
                }
                Text("\(DIAMOND_SYMBOL) \(table.remainingCardCount())")
                    .font(.subheadline)
                    .frame(alignment: .leading)
                    .foregroundColor(FOREGROUND)
                if (self.table.settings.showPartialSetSelectedIndicator) {
                    if (self.table.state.blinking || self.table.selectedCards().isSet()) {
                            Text(HAPPY_FACE_SYMBOL)
                                .font(.subheadline)
                                .frame(alignment: .leading)
                                .foregroundColor(FOREGROUND)
                    }
                    else if (self.table.state.partialSetSelected) {
                        if (self.table.selectedCardCount() == 1) {
                            Text(OK_SYMBOL)
                                .font(.subheadline)
                                .frame(alignment: .leading)
                                .foregroundColor(FOREGROUND)
                        }
                        else if (self.table.selectedCardCount() == 2) {
                            Text(THUMBSUP_SYMBOL)
                                .font(.subheadline)
                                .frame(alignment: .leading)
                                .foregroundColor(FOREGROUND)
                        }
                        else {
                            Text(NEUTRAL_FACE_SYMBOL)
                                .font(.subheadline)
                                .frame(alignment: .leading)
                                .foregroundColor(FOREGROUND)
                        }
                    }
                    else if ((self.table.selectedCardCount() == 1) || (self.table.selectedCardCount() == 2)) {
                        Text(SAD_FACE_SYMBOL)
                            .font(.subheadline)
                            .frame(alignment: .leading)
                    }
                    else if (self.table.state.setJustFound || self.table.selectedCards().isSet()) {
                        Text(HAPPY_FACE_SYMBOL)
                            .font(.subheadline)
                            .frame(alignment: .leading)
                    }
                    else if (self.table.state.setJustFoundNot) {
                        Text(SAD_FACE_SYMBOL)
                            .font(.subheadline)
                            .frame(alignment: .leading)
                    }
                    else {
                        Text(NEUTRAL_FACE_SYMBOL)
                            .font(.subheadline)
                            .frame(alignment: .leading)
                    }
                }
            }
            Spacer()
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
                    Image(systemName: "eye")
                        .foregroundColor(self.table.containsSet() ? FOREGROUND : Color.gray)
                        .offset(x: -8, y: 1)
                }
            }
/*
            Button(action: {
                self.table.state.showingCardsWhichArePartOfSet.toggle();
                if (self.table.state.showingCardsWhichArePartOfSet) {
                    self.table.selectAllCardsWhichArePartOfSet();
                }
                else {
                    self.table.unselectCards();
                }
            }) {
                Image(systemName: "target")
                    .foregroundColor(self.table.containsSet() ? Color.blue : Color.gray)
                    .offset(y: 2)
            }
*/
/*
            Button(action: { self.table.addMoreCards(1) }) {
                Image(systemName: "plus.app")
                    .foregroundColor(self.table.remainingCardCount() > 0 ? Color.blue : Color.gray)
                    .offset(y: 2)
            }
*/
/*
            Button(action: { self.table.startNewGame() }) {
                Image(systemName: "arrow.clockwise.circle")
                    .offset(y: 2)
            }
*/
        }
        // .offset(y: 2)
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
                .frame(height: 34)
                //
                // This padding-horizontal controls the internal left/right padding of control as a whole.
                //
                .padding(.horizontal, 0)
                //
                // This shadow-radius controls the soft drop shadow around/behind the control.
                // though can't really see a different with it on/off or high/low.
                //
                .shadow(radius: 1)
        )
        .background(BACKGROUND)
        .allowsHitTesting(!self.table.state.blinking && !self.table.settings.demoMode)
    }
}

/*
struct StatusBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarView()
            .environmentObject(Table(displayCardCount: 12, plantSet: true))
    }
}
*/
extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255
        )
    }
}
