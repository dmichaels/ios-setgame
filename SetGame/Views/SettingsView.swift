import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;

    // @State private var alternateCards: Int = 0
    @State private var showResetConfirmation = false

    private let iconWidth: CGFloat = 30;
    private let CardsPerRowChoices: [Int] = [ 2, 3, 4, 5, 6 ];
    private let DisplayCardCountChoices: [Int] = [ 3, 4, 6, 9, 12, 15, 16, 18, 20 ];
    private let AdditionalCardsChoices: [Int] = [ 0, 1, 2, 3 ];
    private let AlternateCardsChoices: [(label: String, value: Int)] = [ ("Classic", 0),
                                                                         ("Squares", 1),
                                                                         ("Monochrome", 2) ]
    var body: some View {
        Form {
            Section(header: Text("Informational")) {
                HStack {
                    Image(systemName: "face.smiling").frame(width: iconWidth)
                    Text("Partial SET Hint").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $settings.showPartialSetHint) {}
                    
                }
                HStack {
                    Image(systemName: "number.square").frame(width: iconWidth)
                    Text("Available SET Count").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $settings.showSetsPresentCount) {}
                }
                HStack {
                    Image(systemName: "eyes").frame(width: iconWidth)
                    Text("Peek SET Button")
                    Spacer()
                    Toggle(isOn: $settings.showPeekButton) {}
                }
                HStack {
                    Image(systemName: "square.on.square.intersection.dashed").frame(width: iconWidth)
                    Text("Disjoint Peek & Count ↑")
                        .foregroundStyle(settings.showSetsPresentCount || settings.showPeekButton ? .primary : .secondary)
                        .lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $settings.peekDisjoint) {}
                }.disabled(!(settings.showSetsPresentCount || settings.showPeekButton))
            }
            Section(header: Text("Behavioral")) {
                HStack {
                    Image(systemName: "plus.square.on.square").frame(width: iconWidth)
                    Text("No SETs → More Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Picker("", selection: $settings.additionalCards) {
                        ForEach(AdditionalCardsChoices, id: \.self) {
                            Text("\($0)").tag("\($0)")
                        }
                    }.pickerStyle(.menu)
                }
                HStack {
                    Image(systemName: "target").frame(width: iconWidth)
                    Text("Plant SET").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $settings.plantSet) {}
                }
                HStack {
                    Image(systemName: "arrow.up.left.square").frame(width: iconWidth)
                    Text("Move SET Front").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $settings.moveSetFront) {}
                }
                HStack {
                    Image(systemName: "wand.and.rays").frame(width: iconWidth)
                    Text("Plant Magic Square").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $settings.plantMagicSquare) {}
                }
            }
            Section(header: Text("Visual")) {
                HStack {
                    Image(systemName: "list.number").frame(width: iconWidth)
                    Text("Show Found SETs").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $settings.showFoundSets) {}
                }
                HStack {
                    Image(systemName: "square.on.square").frame(width: iconWidth)
                    Text("Cards Displayed").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Picker("", selection: $settings.displayCardCount) {
                        ForEach(DisplayCardCountChoices, id: \.self) {
                            Text(String($0))
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                HStack {
                    Image(systemName: "square.grid.3x3").frame(width: iconWidth)
                    Text("Cards Per Row").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Picker("", selection: $settings.cardsPerRow) {
                        ForEach(CardsPerRowChoices, id: \.self) {
                            Text(String($0))
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                HStack {
                    Image(systemName: "skew").frame(width: iconWidth)
                    Text("Skew Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $settings.cardsAskew) {}
                }
                HStack {
                    Image(systemName: "waveform.path").frame(width: iconWidth)
                    Text("Shake Table").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $settings.shakeTableOnNonSet) {}
                }
                HStack {
                    Image(systemName: "photo").frame(width: iconWidth)
                    Text("Cards Images").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Picker("", selection: $settings.alternateCards) {
                        ForEach(AlternateCardsChoices, id: \.value) { option in Text(option.label) }
                    }
                    .pickerStyle(.menu)
                }
            }
            Section(header: Text("Multimedia")) {
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
                    Toggle(isOn: $settings.simpleDeck) {}
                }
                if (false) {
                    Toggle(isOn: $settings.demoMode) {
                        Text("Demo Mode")
                    }
                }
                navigationRow("\(Defaults.title) SET Stats", icon: "chart.bar", destination: StatsView())
                navigationRow("\(Defaults.title) Deck", icon: "square.stack.3d.up",
                              destination: DeckView(cards: settings.simpleDeck
                                                           ? StandardDeck.instanceSimple.cards
                                                           : StandardDeck.instance.cards))
            }
            Section {
                Button {
                    showResetConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        // Text("Reset Settings to Original Defaults")
                        Text("Reset Settings")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .foregroundColor(.white)
                }
                .listRowBackground(settings.isDefault() ? Color.secondary : Color.red)
                .disabled(settings.isDefault())
                .accessibilityHint(
                    settings.isDefault()
                    ? "All settings are already at their default values"
                    : "Resets all settings to their defaults"
                )
                .opacity(settings.isDefault() ? 0.5 : 1.0)
            }
            HStack {
                Text("  Version").font(.footnote)
                Spacer()
                Text("\(VersionInfo.version).\(VersionInfo.build) ").font(.footnote)
            }
            HStack {
                Text("  Commit ID").font(.footnote)
                Spacer()
                Text("\(VersionInfo.commit) ").font(.footnote)
            }
        }
        .navigationTitle("\(Defaults.title) Settings")
        .alert("Reset Settings?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) { settings.reset() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will restore all settings to their original defaults.")
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
}
