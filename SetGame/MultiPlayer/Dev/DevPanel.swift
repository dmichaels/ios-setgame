import SwiftUI

private struct SessionInfo {
    public var session: String? = nil;
}

private struct ServerInfo {
    public var sessions: [String] = ["-", "ABC", "DEF", "GHI"];
}

private func SID(_ session: String?) -> String {
    return String((session ?? "∅").prefix(5));
}

public extension MultiPlayer {

    public struct DevPanel: View {

        @ObservedObject var table: Table
        @ObservedObject var settings: Settings;
                        var margin: Int = 10;
                        var background: Color = Color(hex: 0x8BD2CC);
                        var horizontalPadding: Int = 10;
                        var separationPadding: Int = 10;

        let session: MultiPlayer.Session;
        let transport: MultiPlayer.HttpTransport;

        @State private var sessionInfo: SessionInfo = SessionInfo();
        @State private var serverInfo: ServerInfo = ServerInfo();
        @State private var sessionSelected: String = "-";
               private let poller: Poller = Poller(seconds: 2);

        public init(table: Table, settings: Settings, margin: Int) {
            self.table = table;
            self.settings = settings;
            self.margin = margin;
            self.session = MultiPlayer.HttpSession.instance;
            self.transport = MultiPlayer.HttpSession.instance.transport as! MultiPlayer.HttpTransport;
        }

        public var body: some View {
            Spacer().frame(height: CGFloat(margin))
            AnyDevPanel(table: table, settings: settings) {
                HStack(spacing: CGFloat(separationPadding)) {
                    SessionCreateButton(sessionInfo: $sessionInfo, serverInfo: $serverInfo, session: session, transport: transport)
                    Text("\(SID(sessionInfo.session))")
                    Spacer()
                    DropDown(items: $serverInfo.sessions, selected: $sessionSelected)
                }
                .padding(.horizontal, CGFloat(horizontalPadding))
            }
            .onAppear {
                self.poller.start();
            }
        }
    }
}

private struct SessionCreateButton: View {

    @Binding fileprivate var sessionInfo: SessionInfo;
    @Binding fileprivate var serverInfo: ServerInfo;
                         let session: MultiPlayer.Session;
                         let transport: MultiPlayer.HttpTransport;

    public var body: some View {
            Button {
                Task {
                    if (session.session == nil) {
                        if await session.create() {
                            sessionInfo.session = session.session;
                        }
                    }
                    else {
                        if let sessions: [String] = await transport.retrieveSessions() {
                            // serverInfo.sessions = sessions;
                            // serverInfo.sessions = sessions.map { SID($0) }
                            serverInfo.sessions =  minimalUniquePrefixes(sessions);
                        }
                    }
                }
            } label: {
                Image(systemName: session.session == nil ? "plus.message" : "plus.message.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            .padding(.trailing, 10)
    }
}

private struct DropDown: View {
    
    @Binding public var items: [String];
    @Binding public var selected: String;
    
    public var body: some View {
        /*
        Picker("Select Item", selection: $selected) {
            ForEach(items, id: \.self) { item in
                Text(item).tag(item)
            }
        }
        .pickerStyle(.menu)   // .menu, .segmented, .wheel, etc.
        */
        Picker(selection: $selected) {
            ForEach(items, id: \.self) { item in
                Text(item).tag(item)
            }
        } label: {
            Text(selected.isEmpty ? "Select…" : selected)
        }
        // .pickerStyle(.menu)
        // .frame(minWidth: 120)
        // .fixedSize()
        .onAppear {
            if selected.isEmpty, let first = items.first {
                selected = first
            }
        }
    }
}

private struct AnyDevPanel<Content: View>: View {

    @ObservedObject var table: Table
    @ObservedObject var settings: Settings
    private let content: Content

    var height: CGFloat = 38;
    var padding: CGFloat = 8;
    var background: Color = Color(hex: 0x8BD2CC);

    public init(
        table: Table,
        settings: Settings,
        @ViewBuilder content: () -> Content
    ) {
        self.table = table
        self.settings = settings
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: padding) {
            Spacer()
            HStack(alignment: .firstTextBaseline) { // .center
                content
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(background)
                    .opacity(0.8)
                    .frame(height: height)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 3, y: 6)
            )
            Spacer()
        }
    }
}

private class Poller {

    private let interval: UInt64;
    private var task: Task<Void, Never>? = nil;

    public init(seconds: Int = 2) {
        self.interval = UInt64(seconds * 1_000_000_000);
    }

    public init(milliseconds: Int = 2) {
        self.interval = UInt64(milliseconds * 1_000_000);
    }

    public func start() {
        guard self.task == nil else { return }
        self.task = Task {
            while (!Task.isCancelled) {
                try? await Task.sleep(nanoseconds: self.interval);
            }
        }
    }

    public func stop() {
        task?.cancel();
        task = nil;
    }
}


// Returns the given array of strings, which is assumed to contain UNIQUE values,
// where each value is truncated to the first, at mininum, the given minimum number
// of characters; but if not, then the prefix length will be chosen such that the
// result values will be unique. From ChatGPT wholesale.
//
private func minimalUniquePrefixes(_ items: [String], min: Int = 4) -> [String] {
    guard !items.isEmpty else { return [] }
    var result = Array(repeating: "", count: items.count)
    var prefixLength = min
    while true {
        var seen = Set<String>()
        var collision = false
        for (i, item) in items.enumerated() {
            let prefix = String(item.prefix(prefixLength))
            result[i] = prefix
            if seen.contains(prefix) {
                collision = true
            } else {
                seen.insert(prefix)
            }
        }
        if !collision {
            return result
        }
        prefixLength += 1
    }
}
