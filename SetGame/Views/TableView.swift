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

    @State var multiPlayerHost: Bool = true;
    @State var multiPlayerPoll: Bool = true;

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CardGridView(table: table, settings: settings, spacing: spacing, marginx: marginx)
            Space(size: 18)
            StatusBar(marginx: marginx)
            Space(size: 24)
            MultiPlayerControlPanel(table: table, settings: settings)
            Space(size: 4)
            MultiPlayerInfoPanel(table: table, settings: settings)
            Space(size: 12)
            FoundSets(table: table, settings: settings, marginx: marginx)
            DebugView(table: table)
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
    @ObservedObject var table: Table;
    var body: some View { HStack {
        // Button { Task {
        //     print("HTTP-GET>")
        //     let transport: GameCenter.HttpTransport = GameCenter.HttpTransport(player: "A");
        //     let messages: [GameCenter.Message] = await transport.retrieveMessages(for: "A");
        //     print("HTTP-GET> messages: \(messages)")
        //     print("HTTP-GET> done")
        // } } label: { Text("HTTP-GET") }
        Button { Task {
            print("HTTP-POST>")
            let transport: GameCenter.Transport = GameCenter.HttpTransport.instance;
            let cards: [TableCard] = [TableCard("ROS1")!, TableCard("ROS2")!, TableCard("ROS3")!];
            let message: GameCenter.Message = GameCenter.FoundSetMessage(player: GameCenter.HttpTransport.instance.player, cards: cards);
            print("HTTP-POST> send player: \(GameCenter.HttpTransport.instance.player)")
            print(message)
            transport.send(message: message);
            print("HTTP-POST> done")
        } } label: { Text("POST") }
        Button { Task {
            print("HTTP-NEWGAME>")
            let transport: GameCenter.Transport = GameCenter.HttpTransport.instance;
            let cards: [TableCard] = [TableCard("ROS1")!, TableCard("ROS2")!, TableCard("ROS3")!];
            let message: GameCenter.Message = GameCenter.NewGameMessage(player: GameCenter.HttpTransport.instance.player, cards: cards);
            print("HTTP-NEWGAME> send player: \(GameCenter.HttpTransport.instance.player)")
            print(message)
            transport.send(message: message);
            print("HTTP-NEWGAME> done")
        } } label: { Text("NEWGAME") }
        Button { Task {
            print("HTTP-REGISTER>")
            let transport: GameCenter.Transport = GameCenter.HttpTransport.instance;
            let response = await transport.register();
            print(response);
            print("HTTP-REGISTER> done")
        } } label: { Text("REG") }
        Button { Task {
            print("HTTP-REGISTER>")
            let transport: GameCenter.Transport = GameCenter.HttpTransport.instance;
            let response = await transport.reset();
            print(response);
            print("HTTP-REGISTER> done")
        } } label: { Text("RESET") }
        Button {
            table.cards[0].materialize(responsivity: 1.5, elasticity: 0.8);
        } label: { Text("MAT") }
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
