import SwiftUI

struct HelpView: View  {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;

    private let lines: [String];

    @State private var resetMagicSquare: Bool = false;
    @State private var magicSquare: [TableCard] = Deck.randomMagicSquare().map { TableCard($0) }

    init() {
        let text = (try? String(contentsOf: Bundle.main.url(forResource: "Help", withExtension: "md")!))
            ?? "Missing Help.md"
        self.lines = text.components(separatedBy: .newlines)
    }

    var body: some View {
        let alternateCards: Int = self.settings.alternateCards != 2 ? self.settings.alternateCards : 1;
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    let line: String = self.mapLine(line, alternateCards);
                    HStack {
                        if line.hasPrefix("## ") {
                            Text(line.dropFirst(3))
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.top, 8)
                        }
                        else if line == "EXAMPLE-1" {
                            HStack {
                                CardView(card: TableCard("1RHO")!, alternate: alternateCards)
                                CardView(card: TableCard("2GSD")!, alternate: alternateCards)
                                CardView(card: TableCard("3PTQ")!, alternate: alternateCards)
                                Spacer()
                            } .frame(width: 300, height: 80)
                        }
                        else if line == "EXAMPLE-2" {
                            HStack {
                                CardView(card: TableCard("1RHO")!, alternate: alternateCards)
                                CardView(card: TableCard("1RHD")!, alternate: alternateCards)
                                CardView(card: TableCard("1RHQ")!, alternate: alternateCards)
                                Spacer()
                            } .frame(width: 300, height: 80)
                        }
                        else if line == "EXAMPLE-3" {
                            HStack {
                                CardView(card: TableCard("1RHO")!, alternate: 2)
                                CardView(card: TableCard("2GSD")!, alternate: 2)
                                CardView(card: TableCard("3PTQ")!, alternate: 2)
                                Spacer()
                            } .frame(width: 300, height: 80)
                        }
                        else if line == "STATUS-IMAGE-1" {
                            Image("status_bar_example_a")
                                .resizable()
                                .frame(height: 50)
                        }
                        else if line == "MAGIC-SQUARE-1" {
                            HStack(alignment: .top, spacing: 2) {
                                VStack(spacing: 6) {
                                    HStack(spacing: 8) {
                                        CardView(card: magicSquare[0])
                                        CardView(card: magicSquare[1])
                                        CardView(card: magicSquare[2])
                                    }
                                    HStack(spacing: 4) {
                                        CardView(card: magicSquare[3])
                                        CardView(card: magicSquare[4])
                                        CardView(card: magicSquare[5])
                                    }
                                    HStack(spacing: 4) {
                                        CardView(card: magicSquare[6])
                                        CardView(card: magicSquare[7])
                                        CardView(card: magicSquare[8])
                                    }
                                }
                                Spacer()
                                VStack {
                                    Button(action: { magicSquare = Deck.randomMagicSquare().map { TableCard($0) } }) {
                                        HStack(spacing: 3) {
                                            // Image(systemName: "arrow.counterclockwise").font(.subheadline)
                                            Text(" Refresh ").font(.subheadline)
                                                .lineLimit(1)
                                                .fixedSize(horizontal: true, vertical: false)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .fill(Color(hex: 0x104D2F).opacity(0.85))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(Rectangle())
                                    /*
                                    Button(action: { magicSquare[0].selected = true }) {
                                        HStack(spacing: 3) {
                                            Image(systemName: "arrow.counterclockwise").font(.subheadline)
                                            Text(" Show SET ").font(.subheadline)
                                                .lineLimit(1)
                                                .fixedSize(horizontal: true, vertical: false)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .fill(Color(hex: 0x104D2F).opacity(0.85))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(Rectangle())
                                    */
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                            // blank line => paragraph spacing
                            // Spacer().frame(height: 1)
                        }
                        else {
                            // inline markdown still works here (**bold**, *italic*, [link](...))
                            Text(.init(line)).font(.body)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Logicard Help")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func mapLine(_ line: String, _ alternateCards: Int) -> String {
            //
            // Classic.
            //
        if (alternateCards == 0) {
            return line.replacingOccurrences(of: "RED", with: "red")
                       .replacingOccurrences(of: "GREEN", with: "green")
                       .replacingOccurrences(of: "BLUE", with: "purple")
                       .replacingOccurrences(of: "HOLLOW", with: "hollow")
                       .replacingOccurrences(of: "SOLID", with: "solid")
                       .replacingOccurrences(of: "SHADED", with: "stripped")
                       .replacingOccurrences(of: "TRI-BAR", with: "squiggle")
                       .replacingOccurrences(of: "DI-BAR", with: "diamond")
                       .replacingOccurrences(of: "BAR", with: "oval")
        }
        else if (alternateCards == 1) {
            //
            // Squares.
            //
            return line.replacingOccurrences(of: "RED", with: "red")
                       .replacingOccurrences(of: "GREEN", with: "green")
                       .replacingOccurrences(of: "BLUE", with: "blue")
                       .replacingOccurrences(of: "HOLLOW", with: "hollow")
                       .replacingOccurrences(of: "SOLID", with: "solid")
                       .replacingOccurrences(of: "SHADED", with: "shaded")
                       .replacingOccurrences(of: "TRI-BAR", with: "tri-bar")
                       .replacingOccurrences(of: "DI-BAR", with: "di-bar")
                       .replacingOccurrences(of: "BAR", with: "bar")
        }
        else {
            return line;
        }
    }
}

struct HelpViewButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "book.fill")
                    .font(.headline)
                Text("Help")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: 0x104D2F).opacity(0.85))
            )
            .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}
