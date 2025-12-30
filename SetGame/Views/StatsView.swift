import SwiftUI

struct StatsView: View  {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var xsettings : XSettings;

    @State var isViewDisplayed = false;

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                HStack {
                    Text(self.xsettings.simpleDeck
                         ? "Simplified Deck: 27 Cards"
                         : "Standard Deck: 81 Cards") // .font(.footnote).italic()
                    Spacer()
                }
/*
                Divider()
                HStack {
                    Text("Possible SETs: \(String(Deck.numberOfDistinctSets(simple: self.xsettings.simpleDeck)))").font(.footnote)
                    Spacer()
                }
*/
                Rectangle().fill(Color.black).frame(height: 2)
                ForEach(3...Deck.setlessCount(simple: self.xsettings.simpleDeck) , id: \.self) { index in
                    if (index == 3) {
                        HStack {
                            Text("\nNumber\nof Cards")
                                .font(.system(size: 14, design: .monospaced))
                                .frame(alignment: .leading)
                            Spacer()
                            Text("\n\nP(SET)")
                                .font(.system(size: 14, design: .monospaced))
                                .frame(alignment: .trailing)
                            Spacer()
                            Text("Average\n Number\nof SETs")
                                .font(.system(size: 14, design: .monospaced))
                                .frame(alignment: .trailing)
                        }
                        Divider()
                    }
                    HStack {
                        if (self.isViewDisplayed) {
                            let average = Deck.averageNumberOfSets(index, simple: self.xsettings.simpleDeck);
                            // let average = self.table.deck.xaverageNumberOfSets(index);
                            let p = Deck.probabilityOfAtLeastOneSet(for: index, simple: self.xsettings.simpleDeck) * 100.0
                            //
                            // Truncate probability to one decimal place so
                            // that we don't show 100.0% for (say) 99.9996%.
                            ///
                            let probability = Double(Int(p * 10)) / 10.0
                            Text("\(String(format: "%2d", index))")
                                .font(.system(size: 14, design: .monospaced))
                                .frame(alignment: .leading)
                            Spacer()
                            Text("\(String(format: "%6.1f%%", probability))")
                                .font(.system(size: 14, design: .monospaced))
                                .frame(alignment: .trailing)
                            Spacer()
                            Text("\(String(format: "%4.1f", average))")
                                .font(.system(size: 14, design: .monospaced))
                                .frame(alignment: .trailing)
                        }
                    }
                }
                Spacer()
                Spacer()
                Spacer()
                Rectangle().fill(Color.black).frame(height: 2)
                VStack {
                    let distinctSetsDifferencesAny:   Int = Deck.numberOfDistinctSets(simple: self.xsettings.simpleDeck);
                    let distinctSetsDifferencesOne:   Int = Deck.numberOfDistinctSets(simple: self.xsettings.simpleDeck, ndifferences: 1);
                    let distinctSetsDifferencesTwo:   Int = Deck.numberOfDistinctSets(simple: self.xsettings.simpleDeck, ndifferences: 2);
                    let distinctSetsDifferencesThree: Int = Deck.numberOfDistinctSets(simple: self.xsettings.simpleDeck, ndifferences: 3);
                    let distinctSetsDifferencesFour:  Int = Deck.numberOfDistinctSets(simple: self.xsettings.simpleDeck, ndifferences: 4);
                    let percentSetsDifferencesAny:    Float = (Float(distinctSetsDifferencesAny)   / Float(distinctSetsDifferencesAny)) * 100.0;
                    let percentSetsDifferencesOne:    Float = (Float(distinctSetsDifferencesOne)   / Float(distinctSetsDifferencesAny)) * 100.0;
                    let percentSetsDifferencesTwo:    Float = (Float(distinctSetsDifferencesTwo)   / Float(distinctSetsDifferencesAny)) * 100.0;
                    let percentSetsDifferencesThree:  Float = (Float(distinctSetsDifferencesThree) / Float(distinctSetsDifferencesAny)) * 100.0;
                    let percentSetsDifferencesFour:   Float = (Float(distinctSetsDifferencesFour)  / Float(distinctSetsDifferencesAny)) * 100.0;
                    HStack {
                        Text("SET\nAttribute\nDifferences")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .leading)
                        Spacer()
                        Text("\n\n    SETs")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .trailing)
                        Spacer()
                        Text("\n\nPercentage")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .trailing)
                    }
                    Divider()
                    HStack {
                        Text("One")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .leading)
                        Spacer()
                        Text("\(String(format: "%10d", distinctSetsDifferencesOne))")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .trailing)
                        Spacer()
                        Text("\(String(format: "%3.0f", percentSetsDifferencesOne))%")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .trailing)
                    }
                    HStack {
                        Text("Two")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .leading)
                        Spacer()
                        Text("\(String(format: "%10d", distinctSetsDifferencesTwo))")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .trailing)
                        Spacer()
                        Text("\(String(format: "%3.0f", percentSetsDifferencesTwo))%")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .trailing)
                    }
                    HStack {
                        Text("Three")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .leading)
                        Spacer()
                        Text("\(String(format: "%8d", distinctSetsDifferencesThree))")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .trailing)
                        Spacer()
                        Text("\(String(format: "%3.0f", percentSetsDifferencesThree))%")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .trailing)
                    }
                    if (!self.xsettings.simpleDeck) {
                        HStack {
                            Text("Four")
                                .font(.system(size: 14, design: .monospaced))
                                .frame(alignment: .leading)
                            Spacer()
                            Text("\(String(format: "%9d", distinctSetsDifferencesFour))")
                                .font(.system(size: 14, design: .monospaced))
                                .frame(alignment: .trailing)
                            Spacer()
                            Text("\(String(format: "%3.0f", percentSetsDifferencesFour))%")
                                .font(.system(size: 14, design: .monospaced))
                                .frame(alignment: .trailing)
                        }
                    }
                    Divider()
                    HStack {
                        Text("Any/Total")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .leading)
                        Spacer()
                        Text("\(String(format: "%4d", distinctSetsDifferencesAny))")
                            .font(.system(size: 14, design: .monospaced)).bold()
                            .frame(alignment: .trailing)
                        Spacer()
                        Text("\(String(format: "%3.0f", percentSetsDifferencesAny))%")
                            .font(.system(size: 14, design: .monospaced))
                            .frame(alignment: .trailing)
                    }
                    Divider()
                }
            }.padding(30)
            .onAppear {
                self.isViewDisplayed = true
            }
            .onDisappear {
                self.isViewDisplayed = false
            }
            
        }.navigationTitle("Logicard Stats")
    }
}
