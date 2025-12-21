import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    let cardsPerRowChoices = [ 2, 3, 4, 5, 6 ];
    let preferredDisplayCountCardChoices = [ 3, 4, 6, 9, 12, 15, 16, 18, 20 ];
    let limitDeckSizeChoices = [ 18, 27, 36, 45, 54, 63, 72, 81 ];
    
    var body: some View {
        // ScrollView(.vertical, showsIndicators: false) {
            Form {
                Section(header: Text("Informational")) {
                    Toggle(isOn: $table.settings.showPartialSetSelectedIndicator) {
                        Text("Partial SET Hint ")
                    }
                    Toggle(isOn: $table.settings.showNumberOfSetsPresent) {
                        Text("Available SETs Count ")
                    }
                    Toggle(isOn: $settings.showPeekButton) {
                        Text("Peek Button")
                    }
                }
                Section(header: Text("Behavioral")) {
                    Toggle(isOn: $table.settings.moreCardsIfNoSet) {
                        Text("No SETs → More Cards")
                    }
                    Toggle(isOn: $table.settings.plantSet) {
                        Text("Plant SET ")
                    }
                    if (false) {
                        Toggle(isOn: $table.settings.moveAnyExistingSetToFront) {
                            Text("Move SET Front ")
                        }
                    }
                    Toggle(isOn: $table.settings.plantInitialMagicSquare) {
                        Text("Plant Magic Square ")
                    }
                }
                Section(header: Text("Visual")) {
                    Toggle(isOn: $table.settings.showFoundSets) {
                        Text("Show Found SETs ")
                    }
                    HStack() {
                        Text("Display Cards")
                        Spacer()
                        Picker("", selection: $table.settings.displayCardCount) {
                            ForEach(preferredDisplayCountCardChoices, id: \.self) {
                                Text(String($0))
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                    HStack() {
                        Text("Cards Per Row")
                        Spacer()
                        Picker("", selection: $table.settings.cardsPerRow) {
                            ForEach(cardsPerRowChoices, id: \.self) {
                                Text(String($0))
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                    Toggle(isOn: $table.settings.cardsAskew) {
                        Text("Skew Cards")
                    }
                    if (true) {
                        Toggle(isOn: $table.settings.alternateCardImages) {
                            Text("Alternate Cards")
                        }
                    }
                }
                Section(header: Text("MULTIMEDIA")) {
                    Toggle(isOn: $settings.sounds) {
                        Text("Sounds")
                    }
                    Toggle(isOn: $settings.haptics) {
                        Text("Haptics")
                    }
                }
                Section(header: Text("Game")) {
                    Toggle(isOn: $table.settings.useSimpleDeck) {
                        Text("Simplified Deck")
                    }
                    if (false) {
                        Toggle(isOn: $table.settings.demoMode) {
                            Text("Demo Mode")
                        }
                    }
                    navigationRow("SET Stats", destination: StatsView())
                    navigationRow("SET Cards", destination: DeckView(cards: table.settings.useSimpleDeck ? StandardDeck.instanceSimple.cards : StandardDeck.instance.cards))
                }
            }
/*
            Form {
                // Divider()
                Section() {
                Toggle(isOn: $table.settings.showPartialSetSelectedIndicator) {
                    Text("Partial SET Hint ")
                }
                Toggle(isOn: $table.settings.showNumberOfSetsPresent) {
                    Text("Available SETs Count ")
                }
}
                Divider()
                Toggle(isOn: $table.settings.moreCardsIfNoSet) {
                    Text("No SETs → More Cards")
                }
                Toggle(isOn: $table.settings.plantSet) {
                    Text("Plant SET ")
                }
/*
                Toggle(isOn: $table.settings.moveAnyExistingSetToFront) {
                    Text("Move SET Front ")
                }
*/
                // Divider()
                Toggle(isOn: $table.settings.plantInitialMagicSquare) {
                    Text("Plant Magic Square ")
                }
                // Divider()
                Toggle(isOn: $table.settings.showFoundSets) {
                    Text("Show Found SETs ")
                }
                HStack() {
                    Text("Display Card Count")
                        .frame(alignment: .leading)
                    Spacer()
                    Picker("\(table.settings.displayCardCount) \u{25BC}", selection: $table.settings.displayCardCount) {
                        ForEach(preferredDisplayCountCardChoices, id: \.self) {
                            Text(String($0))
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                HStack() {
                    Text("Cards Per Row")
                        .frame(alignment: .leading)
                    Spacer()
                    Picker("\(table.settings.cardsPerRow) \u{25BC}", selection: $table.settings.cardsPerRow) {
                        ForEach(cardsPerRowChoices, id: \.self) {
                            Text(String($0))
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                Toggle(isOn: $table.settings.cardsAskew) {
                    Text("Skew Cards")
                }
/*
                Toggle(isOn: $table.settings.alternateCardImages) {
                    Text("Alternate Cards")
                }
*/
/*
                Toggle(isOn: $table.settings.demoMode) {
                    Text("Demo Mode")
                }
*/
                // Divider()
                VStack {
                    Toggle(isOn: $table.settings.useSimpleDeck) {
                        //
                        // 2025-12-08
                        // No longer automatically restart when requesting simplifed deck in settings.
                        // Text("Use Simplified Deck ↻ Restarts!")
                        //
                        Text("Simplified Deck")
                    }
                    /*
                    HStack() {
                        Text("Deck Size")
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
                // Divider()
                navigationRow("SET Stats", destination: StatsView())
                // Divider()
                navigationRow("SET Cards", destination: DeckView(cards: table.settings.useSimpleDeck ? StandardDeck.instanceSimple.cards : StandardDeck.instance.cards))
                // Divider()
                HStack {
                    Text("Version").frame(alignment: .leading).font(.footnote)
                    Spacer()
                    Text(self.version()).font(.footnote)
                }
            } // .padding()
*/
        // }
        .navigationTitle("SET Settings")
        .onDisappear {
            self.settings.version += 1
        }
    }

    private func navigationRow<Destination: View>(_ title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title).foregroundColor(.primary)
            }
            .contentShape(Rectangle()) // makes whole row tap-able
        }
    }

    private func version() -> String {
        let version: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return (version ?? "version") + (build ?? "build")
    }
}

/*
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Table(displayCardCount: 12, plantSet: true))
    }
}
*/
