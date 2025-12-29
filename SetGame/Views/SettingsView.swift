import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    @EnvironmentObject var xsettings : XSettings;

    @State private var alternateCards: Int = 0
    @State private var additionalCards: Int = 0

    private let cardsPerRowChoices: [Int] = [ 2, 3, 4, 5, 6 ];
    private let preferredDisplayCountCardChoices: [Int] = [ 3, 4, 6, 9, 12, 15, 16, 18, 20 ];
    private let limitDeckSizeChoices: [Int] = [ 18, 27, 36, 45, 54, 63, 72, 81 ];
    private let iconWidth: CGFloat = 30;
    private let additionalCardsChoices: [Int] = [ 0, 1, 2, 3, ];

/*
    private var additionalCards: Binding<Int> {
        Binding( get: { xsettings.additionalCards }, set: { xsettings.additionalCards = $0 })
    }
*/
    
    var body: some View {
        Form {
            Section(header: Text("Informational")) {
                HStack {
                    Image(systemName: "face.smiling").frame(width: iconWidth)
                    Text("Partial SET Hint").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.showPartialSetHint) {}
                    
                }
                HStack {
                    Image(systemName: "number.square").frame(width: iconWidth)
                    Text("Available SET Count").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.showSetsPresentCount) {}
                }
                HStack {
                    Image(systemName: "eyes").frame(width: iconWidth)
                    Text("Peek SET Button")
                    Spacer()
                    Toggle(isOn: $settings.showPeekButton) {}
                }
                HStack {
                    Image(systemName: "square.on.square.intersection.dashed").frame(width: iconWidth)
                    // Text("Disjoint Peek/Count (↑)")
                    Text("Disjoint Peek & Count ↑")
                        .foregroundStyle(table.settings.showSetsPresentCount || settings.showPeekButton ? .primary : .secondary)
                    Spacer()
                    Toggle(isOn: $settings.peekDisjoint) {}
                }.disabled(!(table.settings.showSetsPresentCount || settings.showPeekButton))
            }
            Section(header: Text("Behavioral")) {
                HStack {
                    Image(systemName: "plus.square.on.square").frame(width: iconWidth)
                    Text("No SETs → More Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Picker("", selection: $xsettings.additionalCards) {
                        ForEach(additionalCardsChoices, id: \.self) {
                            Text("\($0)").tag("\($0)")
                        }
                    }.pickerStyle(.menu)
                    .onAppear {
                        additionalCards = xsettings.additionalCards;
                    }
                    .onChange(of: additionalCards) { value in
                        xsettings.additionalCards = value;
                    }
                }
/*
                HStack {
                    Image(systemName: "plus.square.on.square").frame(width: iconWidth)
                    Text("No SETs → More Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Picker("", selection: self.additionalCards) {
                        ForEach(AdditionalCards, id: \.value) { option in
                            Text(option.label).tag(option.value)
                        }
                    }.pickerStyle(.menu)
                }
*/
/*
                HStack {
                    Image(systemName: "plus.square.on.square").frame(width: iconWidth)
                    Text("No SETs → More Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.moreCardsIfNoSet) {}
                }
*/
                HStack {
                    Image(systemName: "target").frame(width: iconWidth)
                    Text("Plant SET").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.plantSet) {}
                }
                HStack {
                    Image(systemName: "arrow.up.left.square").frame(width: iconWidth)
                    Text("Move SET Front").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.moveSetFront) {}
                }
                HStack {
                    Image(systemName: "wand.and.rays").frame(width: iconWidth)
                    Text("Plant Magic Square").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.plantMagicSquare) {}
                }
            }
            Section(header: Text("Visual")) {
                HStack {
                    Image(systemName: "list.number").frame(width: iconWidth)
                    Text("Show Found SETs").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.showFoundSets) {}
                }
                HStack {
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
                    Image(systemName: "photo").frame(width: iconWidth)
                    Text("Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Picker("", selection: $alternateCards) {
                        ForEach(AlternateCards, id: \.value) { option in Text(option.label) }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: alternateCards) { value in
                        switch value {
                            case 0:  table.settings.alternateCards = 0;
                            case 1:  table.settings.alternateCards = 1;
                            case 2:  table.settings.alternateCards = 2;
                            default: table.settings.alternateCards = 0;
                        }
                    }
                    .onAppear {
                        if      (table.settings.alternateCards == 0) { self.alternateCards = 0 }
                        else if (table.settings.alternateCards == 1) { self.alternateCards = 1 }
                        else if (table.settings.alternateCards == 2) { self.alternateCards = 2 }
                    }
                }
                /*
                HStack {
                    Image(systemName: "alternatingcurrent").frame(width: iconWidth)
                    Text("Alternate Cards").lineLimit(1).layoutPriority(1)
                    Spacer()
                    Toggle(isOn: $table.settings.alternateCards) {}
                }
                */
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
                    Toggle(isOn: $table.settings.simpleDeck) {}
                }
                if (false) {
                    Toggle(isOn: $table.settings.demoMode) {
                        Text("Demo Mode")
                    }
                }
                navigationRow("Logicard SET Stats", icon: "chart.bar", destination: StatsView())
                navigationRow("Logicard Deck", icon: "square.stack.3d.up",
                              destination: DeckView(cards: table.settings.simpleDeck
                                                           ? StandardDeck.instanceSimple.cards
                                                           : StandardDeck.instance.cards))
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
        .navigationTitle("Logicard Settings")
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

/*
    private let XAdditionalCards: [Int] = [
        0,
        1,
        2,
        3,
    ]
    private let AdditionalCards: [(label: String, value: Int)] = [
        ("None",  0),
        ("One",   1),
        ("Two",   2),
        ("Three", 3)
    ]
*/

    private let AlternateCards: [(label: String, value: Int)] = [
        ("Classic", 0),
        ("Squares", 1),
        ("Monochrome", 2)
    ]

    private let MoreCards: [(label: String, value: Int)] = [
        ("One More Cards", 0),
        ("Two More Cards", 1),
        ("Three More Cards", 2)
    ]
}
