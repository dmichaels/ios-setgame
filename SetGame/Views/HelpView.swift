import SwiftUI

public struct HelpView: View  {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;

    private let lines: [String];

    @State private var resetMagicSquare: Bool = false;
    @State private var magicSquare: [TableCard] = HelpView.createMagicSquare();
    @State private var magicSquareCurrent: Int? = nil;
    let magicSquareIndices: [[Int]] = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
        [3, 7, 2],
        [5, 7, 0],
        [1, 3, 8],
        [1, 5, 6]
    ]

    init() {
        let text = (try? String(contentsOf: Bundle.main.url(forResource: "Help", withExtension: "md")!))
            ?? "Missing Help.md"
        self.lines = text.components(separatedBy: .newlines)
    }

    public var body: some View {
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
                                CardView(TableCard("1RHO")!, alternate: alternateCards)
                                CardView(TableCard("2GSD")!, alternate: alternateCards)
                                CardView(TableCard("3PTQ")!, alternate: alternateCards)
                                Spacer()
                            } .frame(width: 300, height: 80)
                        }
                        else if line == "EXAMPLE-2" {
                            HStack {
                                CardView(TableCard("1RHO")!, alternate: alternateCards)
                                CardView(TableCard("1RHD")!, alternate: alternateCards)
                                CardView(TableCard("1RHQ")!, alternate: alternateCards)
                                Spacer()
                            } .frame(width: 300, height: 80)
                        }
                        else if line == "EXAMPLE-3" {
                            HStack {
                                CardView(TableCard("1RHO")!, alternate: 2)
                                CardView(TableCard("2GSD")!, alternate: 2)
                                CardView(TableCard("3PTQ")!, alternate: 2)
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
                                        CardView(magicSquare[0])
                                        CardView(magicSquare[1])
                                        CardView(magicSquare[2])
                                    }
                                    HStack(spacing: 4) {
                                        CardView(magicSquare[3])
                                        CardView(magicSquare[4])
                                        CardView(magicSquare[5])
                                    }
                                    HStack(spacing: 4) {
                                        CardView(magicSquare[6])
                                        CardView(magicSquare[7])
                                        CardView(magicSquare[8])
                                    }
                                }
                                Spacer()
                                VStack(spacing: 10) {
                                    Button {
                                        showMagicSquare()
                                    } label: {
                                        Text("Show SET")
                                            .font(.subheadline)
                                            .frame(width: 110)
                                            .padding(.horizontal, 2)
                                            .padding(.vertical, 5)
                                            .foregroundColor(.white)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color(hex: 0x104D2F).opacity(0.85))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    Button {
                                        self.magicSquare = HelpView.createMagicSquare();
                                    } label: {
                                        Text("Refresh")
                                            .font(.subheadline)
                                            .frame(width: 110)
                                            .padding(.horizontal, 2)
                                            .padding(.vertical, 5)
                                            .foregroundColor(.white)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color(hex: 0x104D2F).opacity(0.85))
                                            )
                                    }
                                    .buttonStyle(.plain)
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
        if (alternateCards == 0) {
            //
            // Classic images.
            //
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
            // Squares images.
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

    private static func createMagicSquare() -> [TableCard] {
        return TableDeck.randomMagicSquare();
    }

    private func showMagicSquare() {
        if (self.magicSquareCurrent != nil) {
            for i in self.magicSquareIndices[self.magicSquareCurrent!] {
                self.magicSquare[i].selected = false;
            }
            self.magicSquareCurrent = self.magicSquareCurrent! + 1;
            if (self.magicSquareCurrent! == magicSquareIndices.count) {
                self.magicSquareCurrent = nil;
            }
            else {
                for i in self.magicSquareIndices[self.magicSquareCurrent!] {
                    self.magicSquare[i].selected = true;
                }
            }
        }
        else {
            self.magicSquareCurrent = 0;
            for i in magicSquareIndices[self.magicSquareCurrent!] {
                self.magicSquare[i].selected = true;
            }
        }
    }
}

struct HelpViewButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
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
