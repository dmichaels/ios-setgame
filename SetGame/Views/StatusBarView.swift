import SwiftUI

struct StatusBarView: View {
    
    @EnvironmentObject var table : Table;

    let OK_SYMBOL           : String = "\u{1F44C}";
    let THUMBSUP_SYMBOL     : String = "\u{1F44D}";
    let NEUTRAL_FACE_SYMBOL : String = "\u{1F610}";
    let HAPPY_FACE_SYMBOL   : String = "\u{1F642}";
    let SAD_FACE_SYMBOL     : String = "\u{1F641}";
    let DIAMOND_SYMBOL      : String = "\u{2756}";
    let CHECK_MARK_SYMBOL   : String = "✅";

    // func partialSetSelectedOne() -> Bool { self.table.state.partialSetSelected && table.cards.count == 1; }
    // func partialSetSelectedTwo() -> Bool { self.table.state.partialSetSelected && table.cards.count == 2; }
    private func gameDone() -> Bool { (self.table.deck.count == 0) && !self.table.containsSet(); }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("SETs: \(table.state.setsFoundCount)")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(alignment: .leading)
                .foregroundColor(Color.blue)
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
                }
                Text("\(DIAMOND_SYMBOL) \(table.remainingCardCount())")
                    .font(.subheadline)
                    .frame(alignment: .leading)
                if (self.table.settings.showPartialSetSelectedIndicator) {
                    if (self.table.state.blinking) {
                            Text(HAPPY_FACE_SYMBOL)
                                .font(.subheadline)
                                .frame(alignment: .leading)
                    }
                    else if (self.table.state.partialSetSelected) {
                        if (self.table.selectedCardCount() == 1) {
                            Text(OK_SYMBOL)
                                .font(.subheadline)
                                .frame(alignment: .leading)
                        }
                        else if (self.table.selectedCardCount() == 2) {
                            Text(THUMBSUP_SYMBOL)
                                .font(.subheadline)
                                .frame(alignment: .leading)
                        }
                        else {
                            Text(NEUTRAL_FACE_SYMBOL)
                                .font(.subheadline)
                                .frame(alignment: .leading)
                        }
                    }
                    else if ((self.table.selectedCardCount() == 1) || (self.table.selectedCardCount() == 2)) {
                        Text(SAD_FACE_SYMBOL)
                            .font(.subheadline)
                            .frame(alignment: .leading)
                    }
                    else if (self.table.state.setJustFound) {
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
                    .foregroundColor(self.table.containsSet() ? Color.blue : Color.gray)
                    .offset(y: 2)
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
