import SwiftUI

struct StatsView: View  {
    
    @EnvironmentObject var table : Table;
    @State var isViewDisplayed = false;

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(3...21, id: \.self) { index in
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
                            let average = Deck.averageNumberOfSets(index);
                            let p = Deck.probabilityOfAtLeastOneSet(for: index) * 100.0
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
            }.padding(30)
            .onAppear {
                self.isViewDisplayed = true
            }
            .onDisappear {
                self.isViewDisplayed = false
            }
            
        }.navigationTitle("SET Stats")
    }
}

/*
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(Table(displayCardCount: 12, plantSet: true))
    }
}
*/
