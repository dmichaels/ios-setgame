import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var table : Table;
    let cardsPerRowChoices = [ 1, 2, 3, 4, 5, 6 ];
    let preferredDisplayCountCardChoices = [ 3, 4, 6, 9, 12, 15, 16, 20 ];
    let limitDeckSizeChoices = [ 18, 27, 36, 45, 54, 63, 72, 81 ];
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                VStack {
                    Divider()
                    Toggle(isOn: $table.settings.showPartialSetSelectedIndicator) {
                        Text("Partial SET Select Hint: ")
                    }
                    Toggle(isOn: $table.settings.showNumberOfSetsPresent) {
                        Text("Present SETs Count: ")
                    }
                    Toggle(isOn: $table.settings.moreCardsIfNoSet) {
                        Text("More Cards On No SET: ")
                    }
                    Divider()
                    Toggle(isOn: $table.settings.plantSet) {
                        Text("Plant SET: ")
                    }
                    Toggle(isOn: $table.settings.moveAnyExistingSetToFront) {
                        Text("Move SET To Front: ")
                    }
                    Divider()
                    Toggle(isOn: $table.settings.plantInitialMagicSquare) {
                        Text("Plant Magic Square: ")
                    }
                }
                Divider()
                HStack() {
                    Text("Display Card Count:")
                        .frame(alignment: .leading)
                    Spacer()
                    Picker("\(table.settings.displayCardCount) \u{25BC}", selection: $table.settings.displayCardCount) {
                        ForEach(preferredDisplayCountCardChoices, id: \.self) {
                            Text(String($0))
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                HStack() {
                    Text("Cards Per Row:")
                        .frame(alignment: .leading)
                    Spacer()
                    Picker("\(table.settings.cardsPerRow) \u{25BC}", selection: $table.settings.cardsPerRow) {
                        ForEach(cardsPerRowChoices, id: \.self) {
                            Text(String($0))
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                Divider()
                VStack {
                    Toggle(isOn: $table.settings.useSimpleDeck) {
                        //
                        // 2025-12-08
                        // No longer automatically restart when requesting simplifed deck in settings.
                        // Text("Use Simplified Deck ↻ Restarts!")
                        //
                        Text("Use Simplified Deck")
                    }
                    /*
                    HStack() {
                        Text("Deck Size:")
                            .frame(alignment: .leading)
                        Spacer()
                        Picker("\(table.settings.limitDeckSize) \u{25BC}", selection: $table.settings.limitDeckSize) {
                            ForEach(limitDeckSizeChoices, id: \.self) {
                                Text(String($0))
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                    */
                }
                Divider()
                HStack () {
                    NavigationLink(destination: StatsView()) {
                        Text("SET Game Stats")
                    }
                    Spacer()
                }.frame(alignment: .leading)
            }.padding()
        }
        .navigationTitle("SET Game® Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Table(displayCardCount: 12, plantSet: true))
    }
}
