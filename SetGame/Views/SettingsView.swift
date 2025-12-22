import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    let cardsPerRowChoices: [Int] = [ 2, 3, 4, 5, 6 ];
    let preferredDisplayCountCardChoices: [Int] = [ 3, 4, 6, 9, 12, 15, 16, 18, 20 ];
    let limitDeckSizeChoices: [Int] = [ 18, 27, 36, 45, 54, 63, 72, 81 ];
    let iconWidth: CGFloat = 22;
    
    var body: some View {
        // ScrollView(.vertical, showsIndicators: false) {
            Form {
                Section(header: Text("Informational")) {
                    // Toggle(isOn: $table.settings.showPartialSetSelectedIndicator) {
                        // Text("Partial SET Hint ")
                    // }
                    HStack {
                        Image(systemName: "face.smiling").frame(width: iconWidth)
                        Text("Partial SET Hint").lineLimit(1).layoutPriority(1)
                        Toggle(isOn: $table.settings.showPartialSetSelectedIndicator) {}
                    }
                    // Toggle(isOn: $table.settings.showNumberOfSetsPresent) {
                        // Text("Available SETs Count ")
                    // }
                    HStack {
                        Image(systemName: "number.square").frame(width: iconWidth)
                        Text("Available SETs Count").lineLimit(1).layoutPriority(1)
                        Toggle(isOn: $table.settings.showNumberOfSetsPresent) {}
                    }
                    /*
                    Toggle(isOn: $settings.showPeekButton) {
                        Text("Peek Button")
                    }
                    */
                    HStack {
                        Image(systemName: "eyes").frame(width: iconWidth)
                        Text("Peek Button")
                        Toggle(isOn: $settings.showPeekButton) {}
                    }
                }
                Section(header: Text("Behavioral")) {
                    // Toggle(isOn: $table.settings.moreCardsIfNoSet) {
                        // Text("No SETs → More Cards")
                    // }
                    HStack {
                        Image(systemName: "plus.square.on.square").frame(width: iconWidth)
                        Text("No SETs → More Cards").lineLimit(1).layoutPriority(1)
                        Toggle(isOn: $table.settings.moreCardsIfNoSet) {}
                    }
                    HStack {
                        // Image(systemName: "3.square").frame(width: 22)
                        // Image(systemName: "creditcard.and.numbers").frame(width: 22)
                        Image(systemName: "numbers.rectangle").frame(width: 22)
                        Text("Plant SET").lineLimit(1).layoutPriority(1)
                        Toggle(isOn: $table.settings.plantSet) {}
                    }
                    // Toggle(isOn: $table.settings.plantSet) {
                        // Text("Plant SET ")
                    // }
                    if (false) {
                        Toggle(isOn: $table.settings.moveAnyExistingSetToFront) {
                            Text("Move SET Front ")
                        }
                    }
                    // Toggle(isOn: $table.settings.plantInitialMagicSquare) {
                        // Text("Plant Magic Square ")
                    // }
                    HStack {
                        Image(systemName: "wand.and.rays").frame(width: 22)
                        Text("Plant Magic Square").lineLimit(1).layoutPriority(1)
                        Toggle(isOn: $table.settings.plantInitialMagicSquare) {}
                    }
                }
                Section(header: Text("Visual")) {
                    // Toggle(isOn: $table.settings.showFoundSets) {
                        // Text("Show Found SETs ")
                    // }
                    HStack {
                        Image(systemName: "magnifyingglass").frame(width: iconWidth)
                        Text("Show Found SETs").lineLimit(1).layoutPriority(1)
                        Toggle(isOn: $table.settings.showFoundSets) {}
                    }
                    /*
                    HStack() {
                        Text("Display Cards")
                        Spacer()
                        Picker("", selection: $table.settings.displayCardCount) {
                            ForEach(preferredDisplayCountCardChoices, id: \.self) {
                                Text(String($0))
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                    */
                    HStack {
                        Image(systemName: "square.stack.3d.up").frame(width: iconWidth)
                        Text("Display Cards").lineLimit(1).layoutPriority(1)
                        Picker("", selection: $table.settings.displayCardCount) {
                            ForEach(preferredDisplayCountCardChoices, id: \.self) {
                                Text(String($0))
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                    /*
                    HStack() {
                        Text("Cards Per Row")
                        Spacer()
                        Picker("", selection: $table.settings.cardsPerRow) {
                            ForEach(cardsPerRowChoices, id: \.self) {
                                Text(String($0))
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                    */
                    HStack {
                        Image(systemName: "square.grid.3x3").frame(width: iconWidth)
                        Text("Cards Per Row").lineLimit(1).layoutPriority(1)
                        Picker("", selection: $table.settings.cardsPerRow) {
                            ForEach(cardsPerRowChoices, id: \.self) {
                                Text(String($0))
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                    /*
                    Toggle(isOn: $table.settings.cardsAskew) {
                        Text("Skew Cards")
                    }
                    */
                    HStack {
                        Image(systemName: "skew").frame(width: iconWidth)
                        Text("Skew Cards").lineLimit(1).layoutPriority(1)
                        Toggle(isOn: $table.settings.cardsAskew) {}
                    }
                    /*
                    Toggle(isOn: $table.settings.alternateCardImages) {
                        Text("Alternate Cards")
                    }
                    */
                    HStack {
                        Image(systemName: "alternatingcurrent").frame(width: iconWidth)
                        Text("Alternate Cards").lineLimit(1).layoutPriority(1)
                        Toggle(isOn: $table.settings.alternateCardImages) {}
                    }
                }
                Section(header: Text("MULTIMEDIA")) {
                    HStack {
                        Image(systemName: "speaker.wave.2")
                        Text("Sounds")
                        Toggle(isOn: $settings.sounds) {}
                    }
                    HStack {
                        Image(systemName: "water.waves")
                        Text("Haptics")
                        Toggle(isOn: $settings.haptics) {}
                    }
                }
                Section(header: Text("Game")) {
                    /*
                    Toggle(isOn: $table.settings.useSimpleDeck) {
                        Text("Simplified Deck")
                    }
                    */
                    HStack {
                        Image(systemName: "atom").frame(width: iconWidth)
                        Text("Simplified Deck").lineLimit(1).layoutPriority(1)
                        Toggle(isOn: $table.settings.useSimpleDeck) {}
                    }
                    if (false) {
                        Toggle(isOn: $table.settings.demoMode) {
                            Text("Demo Mode")
                        }
                    }
                    navigationRow("SET Stats", icon: "chart.bar", destination: StatsView())
                    // navigationRow("SET Cards", icon: "square.grid.3x3.square",
                    navigationRow("SET Cards", icon: "square.stack.3d.down.forward",
                                  destination: DeckView(cards: table.settings.useSimpleDeck
                                                               ? StandardDeck.instanceSimple.cards
                                                               : StandardDeck.instance.cards))
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

    private func navigationRow<Destination: View>(_ title: String, icon: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon).frame(width: iconWidth)
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
