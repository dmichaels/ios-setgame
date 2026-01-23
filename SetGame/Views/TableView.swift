import SwiftUI

// This was previously TableView by factored out into this TableView module
// to eliminate references to global environment (@EnvironmentObject)
// state, in order to facilitate multi-player (GameCenter) functionality.
//
public struct TableView: View {

    @ObservedObject var table: Table;
    @ObservedObject var settings: Settings;
    @ObservedObject var feedback: Feedback;

    let marginx: CGFloat = 6;
    let spacing: CGFloat = 6;

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CardGridView(table: table, settings: settings, spacing: spacing, marginx: marginx)
            Space(size: 18)
            StatusBar(marginx: marginx)
            Space(size: 12)
            FoundSets(table: table, settings: settings, marginx: marginx)
            DebugView()
            MultiPlayerGameButton()
        }
        .allowsHitTesting(!self.table.disabled)
    }

    private struct StatusBar: View {
        var marginx: CGFloat = 8;
        var body: some View {
            HStack(spacing: marginx) {
                Spacer()
                StatusBarView()
                Spacer()
            }
        }
    }

    private struct FoundSets: View {
        @ObservedObject var table: Table;
        @ObservedObject var settings: Settings;
        var marginx: CGFloat = 8;
        var body: some View {
            if (self.settings.showFoundSets) {
                HStack(spacing: marginx) {
                    Spacer()
                    FoundSetsView(table: table, settings: settings)
                    Spacer()
                }
            }
        }
    }
}

private struct DebugView: View {
    func receiveMessages(for playerID: String) async -> [String] {
        let url = URL(string: "http://127.0.0.1:5000/receive/\(playerID)")!
        print(url)
        let (data, _) = try! await URLSession.shared.data(from: url)
        print("RAW-DATA")
        print(data)
        print(type(of: data))
        let s = String(data: data, encoding: .utf8)
        print("STRING-DATA")
        print(s)
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
    func sendMessage(_ msg: String, to playerID: String) async {
        let url = URL(string: "http://127.0.0.1:5000/send")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["to": playerID, "message": msg]
        req.httpBody = try? JSONEncoder().encode(payload)
        let _ = try? await URLSession.shared.data(for: req)
    }
    var body: some View { HStack {
        Button {
Task {
            print("HTTP-CALL")
            let data = await receiveMessages(for: "A")
            print("HTTP-CALL-DONE")
            print(data)
}
        } label: {
            Text("HTTP-GET")
        }
        Button { Task {
            print("HTTP-POST")
            let cards: [TableCard] = [TableCard("ROS3")!];
            let message: GameCenter.FoundSetMessage = GameCenter.FoundSetMessage(player: "A", cards: cards);
            if let data: Data = message.serialize() {
                if let stringToSend = String(data: data, encoding: .utf8) {
                    let data = await sendMessage(stringToSend, to: "A")
                    print("HTTP-POST-DONE")
                    print(data)
                }
            }
        } } label: {
            Text("HTTP-POST")
        }
    } }
}

private struct MultiPlayerGameButton: View {
    @ObservedObject private var gameCenter = GameCenterManager.shared;
        var body: some View {
            if (true) {
                PlayButtonView(gameCenter: gameCenter)
                    .padding(.horizontal)
            }
        }
    }
