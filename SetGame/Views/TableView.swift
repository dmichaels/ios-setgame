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
            MultiPlayerDevelopmentPanel(table: table, host: multiPlayerHost, poll: multiPlayerPoll)
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
        } } label: { Text("HTTP-POST") }
        Button {
            table.cards[0].materialize(responsivity: 1.5, elasticity: 0.8);
        } label: { Text("MATERIALIZE") }
    } }
}
private struct MultiPlayerDevelopmentPanel: View {
    @ObservedObject var table: Table
    @State var host: Bool
    @State var poll: Bool
    var body: some View {
VStack(spacing: 80) {
        HStack(alignment: .firstTextBaseline, spacing: 30) {
            toggleGroup(label: "Host:", isOn: $host)
            toggleGroup(label: "Poll:", isOn: $poll)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
        .frame(width: 410)
        // .frame(maxWidth: .infinity) 
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.gray.opacity(0.2))
        )
    } }
    private func toggleGroup(label: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.caption)
                .lineLimit(1)
            Toggle("", isOn: isOn)
                .labelsHidden()
                .scaleEffect(0.65)
        }
    }
}

private struct XMultiPlayerDevelopmentPanel: View {
    @ObservedObject var table: Table;
    @State var host: Bool;
    @State var poll: Bool;
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 30) {
            toggleGroup(label: "Host:", isOn: $host)
            toggleGroup(label: "Poll:", isOn: $poll)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity) 
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.gray.opacity(0.2))
        )
    }
    private func toggleGroup(label: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 5) {
            Text(label)
                .font(.subheadline)
                .lineLimit(1)
                .scaleEffect(0.7)
            Toggle("", isOn: isOn)
                .labelsHidden()
                .scaleEffect(0.7)
        }
    }
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
