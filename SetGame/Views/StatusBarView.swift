import SwiftUI
import Combine

public struct StatusBarView: View {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;

    let OK_SYMBOL           : String = "\u{1F44C}";
    let THUMBSUP_SYMBOL     : String = "\u{1F44D}";
    let NEUTRAL_FACE_SYMBOL : String = "\u{1F610}";
    let HAPPY_FACE_SYMBOL   : String = "\u{1F642}";
    let SAD_FACE_SYMBOL     : String = "\u{1F641}";
    let DIAMOND_SYMBOL      : String = "\u{2756}";
    let CHECK_MARK_SYMBOL   : String = "✅";
    let TIMER_SYMBOL        : String = "\u{023F1}";

    let FOREGROUND: Color = Color(hex: 0x283028);
    // let BACKGROUND: Color = Color(hex: 0xB3D8EE);
    // let BACKGROUND: Color = Color(hex: 0xA2B6DD);
    // let BACKGROUND: Color = Color(hex: 0x7AC1FF);
    let BACKGROUND: Color = Color(hex: 0x8BD2CC);
    let SHAPE = RoundedRectangle(cornerRadius: 11, style: .continuous);

    @Binding public var startTime: Date;
    @State private var now: Date = Date();

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect();

    private var elapsedSeconds: Int {
        Int(now.timeIntervalSince(self.startTime))
    }

    private var minutes: Int {
        elapsedSeconds / 60
    }

    private var seconds: Int {
        elapsedSeconds % 60
    }
    private var timeString: String {
        String(format: "%02d:%02d", minutes, seconds)
    }

    public var body: some View {
        let squeeze: Bool = self.settings.showTimer;
        HStack(alignment: .firstTextBaseline) {
            Text("  **SET**s: **\(table.state.setsFoundCount)**")
                .font(.subheadline)
                .frame(alignment: .leading)
                .foregroundColor(FOREGROUND)
            if (self.table.gameDone()) {
                Text(CHECK_MARK_SYMBOL)
                    .font(.subheadline)
                    .frame(alignment: .leading)
            }
            else {
                Text("\(DIAMOND_SYMBOL)  \(squeeze ? "" : "Deck: ")\(table.remainingCardCount())")
                    .font(.subheadline)
                    .frame(alignment: .leading)
                    .foregroundColor(FOREGROUND)
            }
            if (self.settings.showTimer && !self.settings.demoMode) {
                Text("\(DIAMOND_SYMBOL)  \(timeString)")
                    .font(.subheadline)
                    .frame(alignment: .leading)
                    .foregroundColor(FOREGROUND)
            }
            Spacer()
                if (self.settings.showPartialSetHint) {
                    if (self.table.state.blinking || self.table.selectedCards().isSet()) {
                            Text(HAPPY_FACE_SYMBOL)
                                .scaleEffect(1.2)
                                .font(.subheadline)
                                .foregroundColor(FOREGROUND)
                                .padding(.trailing, self.settings.showSetsPresentCount || settings.showPeekButton ? 4 : 10)
                    }
                    else if (self.table.state.partialSetSelected) {
                        if (self.table.selectedCardCount() == 1) {
                            Text(OK_SYMBOL)
                                .scaleEffect(1.2)
                                .font(.subheadline)
                                .foregroundColor(FOREGROUND)
                                .padding(.trailing, self.settings.showSetsPresentCount || settings.showPeekButton ? 4 : 10)
                        }
                        else if (self.table.selectedCardCount() == 2) {
                            Text(THUMBSUP_SYMBOL)
                                .scaleEffect(1.2)
                                .font(.subheadline)
                                .foregroundColor(FOREGROUND)
                                .padding(.trailing, self.settings.showSetsPresentCount || settings.showPeekButton ? 4 : 10)
                        }
                        else {
                            Text(NEUTRAL_FACE_SYMBOL)
                                .scaleEffect(1.2)
                                .font(.subheadline)
                                .foregroundColor(FOREGROUND)
                                .padding(.trailing, self.settings.showSetsPresentCount || settings.showPeekButton ? 4 : 10)
                        }
                    }
                    else if ((self.table.selectedCardCount() == 1) || (self.table.selectedCardCount() == 2)) {
                        Text(SAD_FACE_SYMBOL)
                            .scaleEffect(1.2)
                            .font(.subheadline)
                            .padding(.trailing, self.settings.showSetsPresentCount || settings.showPeekButton ? 4 : 10)
                    }
                    else if (self.table.state.setJustFound || self.table.selectedCards().isSet()) {
                        Text(HAPPY_FACE_SYMBOL)
                            .scaleEffect(1.2)
                            .font(.subheadline)
                            .padding(.trailing, self.settings.showSetsPresentCount || settings.showPeekButton ? 4 : 10)
                    }
                    else if (self.table.state.setJustFoundNot) {
                        Text(SAD_FACE_SYMBOL)
                            .scaleEffect(1.2)
                            .font(.subheadline)
                            .padding(.trailing, self.settings.showSetsPresentCount || settings.showPeekButton ? 4 : 10)
                    }
                    else {
                        Text(NEUTRAL_FACE_SYMBOL)
                            .scaleEffect(1.2)
                            .font(.subheadline)
                            .frame(alignment: .leading)
                            .padding(.trailing, self.settings.showSetsPresentCount || settings.showPeekButton ? 4 : 10)
                    }
                }
            if (self.settings.showSetsPresentCount) {
                Text("\(table.numberOfSets(disjoint: settings.peekDisjoint))")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundColor(FOREGROUND)
                    .fixedSize()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(FOREGROUND, lineWidth: 1)
                    )
                    .padding(.trailing, settings.showPeekButton ? 3 : 10)
                }
            if (settings.showPeekButton) {
                Button(action: {
                    self.table.state.showingOneRandomSet.toggle();
                    if (self.table.state.showingOneRandomSet) {
                        self.table.selectOneRandomSet(disjoint: settings.peekDisjoint);
                    }
                    else {
                        self.table.unselectCards();
                    }
                }) {
                    Image(systemName: "eyes")
                        .foregroundColor(self.table.containsSet() ? FOREGROUND : Color.gray)
                        .scaleEffect(1.05)
                        .padding(.trailing, 8)
                        .offset(y: 0.5)
                }
            }
        }
        .background(
            //
            // The corner-radius controls how rounded the control window corners are;
            // greater is more rounded.
            //
            SHAPE // RoundedRectangle(cornerRadius: 10, style: .continuous)
                //
                // This fill-thin-material makes the control background blend in with what is behind it.
                //
                // .fill(.white)
                // .fill(Color(UIColor.systemGray4))
                .fill(BACKGROUND)
                // .fill(.thinMaterial)
                //
                // This opacity controls how transparent the (background of) the control is.
                //
                .opacity(0.8)
                //
                // This frame-height controls the height of the control; default without this is fairly short.
                //
                .frame(height: 35)
                //
                // This padding-horizontal controls the internal left/right padding of control as a whole.
                //
                // .padding(.horizontal, 0)
                //
                // This shadow-radius controls the soft drop shadow around/behind the control.
                // though can't really see a different with it on/off or high/low.
                //
                // .shadow(radius: 1)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 3, y: 6)
        )
        // .background(BACKGROUND)
        .allowsHitTesting(!self.table.state.disabled)
        .onReceive(timer) { date in now = date }
        .onChange(of: self.startTime) { value in
            self.startTime = value;
            now = value;
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255
        )
    }
}
