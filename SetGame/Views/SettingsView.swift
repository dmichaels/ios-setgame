import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    let cardsPerRowChoices: [Int] = [ 2, 3, 4, 5, 6 ];
    let preferredDisplayCountCardChoices: [Int] = [ 3, 4, 6, 9, 12, 15, 16, 18, 20 ];
    let limitDeckSizeChoices: [Int] = [ 18, 27, 36, 45, 54, 63, 72, 81 ];
    let iconWidth: CGFloat = 30;
    
    var body: some View {
        Form {
            Section(header: Text("Informational")) {
                HStack {
                    Image(systemName: "face.smiling").frame(width: iconWidth)
                    Text("Partial SET Hint").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.showPartialSetSelectedIndicator) {}
                    
                }
                HStack {
                    Image(systemName: "number.square").frame(width: iconWidth)
                    Text("Available SETs Count").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.showNumberOfSetsPresent) {}
                }
                HStack {
                    Image(systemName: "eyes").frame(width: iconWidth)
                    Text("Peek Button")
                    Spacer()
                    Toggle(isOn: $settings.showPeekButton) {}
                }
            }
            Section(header: Text("Behavioral")) {
                HStack {
                    Image(systemName: "plus.square.on.square").frame(width: iconWidth)
                    Text("No SETs → More Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.moreCardsIfNoSet) {}
                }
                HStack {
                    // Image(systemName: "numbers.rectangle").frame(width: iconWidtn)
                    // Image(systemName: "dot.scope").frame(width: iconWidth)
                    Image(systemName: "target").frame(width: iconWidth)
                    Text("Plant SET").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.plantSet) {}
                }
                HStack {
                    Image(systemName: "arrow.up.left.square").frame(width: iconWidth)
                    Text("Move SET Front").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.moveAnyExistingSetToFront) {}
                }
                HStack {
                    Image(systemName: "wand.and.rays").frame(width: iconWidth)
                    Text("Plant Magic Square").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.plantInitialMagicSquare) {}
                }
            }
            Section(header: Text("Visual")) {
                HStack {
                    // Image(systemName: "magnifyingglass").frame(width: iconWidth)
                    Image(systemName: "list.number").frame(width: iconWidth)
                    Text("Show Found SETs").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.showFoundSets) {}
                }
                HStack {
                    // Image(systemName: "square.stack.3d.up").frame(width: iconWidth)
                    Image(systemName: "square.on.square").frame(width: iconWidth)
                    Text("Display Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Picker("", selection: $table.settings.displayCardCount) {
                        ForEach(preferredDisplayCountCardChoices, id: \.self) {
                            Text(String($0))
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                HStack {
                    Image(systemName: "square.grid.3x3").frame(width: iconWidth)
                    Text("Cards Per Row").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Picker("", selection: $table.settings.cardsPerRow) {
                        ForEach(cardsPerRowChoices, id: \.self) {
                            Text(String($0))
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                HStack {
                    Image(systemName: "skew").frame(width: iconWidth)
                    Text("Skew Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.cardsAskew) {}
                }
                HStack {
                    Image(systemName: "alternatingcurrent").frame(width: iconWidth)
                    Text("Alternate Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.alternateCardImages) {}
                }
            }
            Section(header: Text("MULTIMEDIA")) {
                HStack {
                    Image(systemName: "speaker.wave.2")
                    Text("Sounds")
                    Spacer()
                    Toggle(isOn: $settings.sounds) {}
                }
                HStack {
                    Image(systemName: "water.waves")
                    Text("Haptics")
                    Spacer()
                    Toggle(isOn: $settings.haptics) {}
                }
            }
            Section(header: Text("Game")) {
                HStack {
                    Image(systemName: "atom").frame(width: iconWidth)
                    Text("Simplified Deck").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.useSimpleDeck) {}
                }
                if (false) {
                    Toggle(isOn: $table.settings.demoMode) {
                        Text("Demo Mode")
                    }
                }
                navigationRow("LogiCard SET Stats", icon: "chart.bar", destination: StatsView())
                // navigationRow("SET Cards", icon: "square.stack.3d.down.forward",
                navigationRow("LogiCard Deck", icon: "square.stack.3d.up",
                              destination: DeckView(cards: table.settings.useSimpleDeck
                                                           ? StandardDeck.instanceSimple.cards
                                                           : StandardDeck.instance.cards))
            }
            HStack {
                Text("  Version").font(.footnote)
                Spacer()
                Text("\(version()) ").font(.footnote)
            }
        }
        .navigationTitle("LogiCard Settings")
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
