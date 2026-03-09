import Foundation

@MainActor
public extension MultiPlayer.Dev {

    public class SessionState: ObservableObject {

        @Published public var xsessions: PrefixableList = PrefixableList();
        // Readonly properties (from external POV).
        //
        // @Published public private(set) var session: String? = nil;
        @Published public private(set) var host: String? = nil;
        public                         let player: String;
        public              var hosting: Bool { self.player == (self.host ?? "") }
        // @Published public private(set) var players: [String] = [];
        @Published public var players: [String] = [];
        @Published public private(set) var connected: Bool = false;
        @Published public private(set) var leaveable: Bool = false;
        @Published public private(set) var pingable: Bool = false;
        @Published public private(set) var info: Json = [:];
        // public              var sessionShort: String { self.sessions.shorten(self.session ?? Defaults.emptySetChar) }
        @Published public private(set) var sessionShort: String = "";
        @Published public private(set) var polling: Bool = false;
        @Published public private(set) var pollCount: Int = 0;
        @Published public private(set) var chats: [MultiPlayer.ChatMessage] = [];

        // Read/write properties (from external POV).
        //
        @Published public var debug: Bool = false;
        @Published public var production: Bool = false;
        @Published public var server: String = "";

        @Published public private(set) var session: String? = nil {
            didSet { self.sessionShort = self.sessions.shorten(session ?? Defaults.emptySetChar) }
        }
        @Published public var sessions: SessionList = SessionList() {
            didSet { self.sessionShort = self.sessions.shorten(session ?? Defaults.emptySetChar) }
        }

        // Inaccessible properties (from external POV).
        //
        private var poller: Poller;
        private var pollerAction: (() async -> Void)? = nil;

        public init(player: String, pollInterval: Int) {
            self.player = player;
            poller = Poller(milliseconds: pollInterval);
        }

        public /*mutating*/ func poll(enable: Bool) {
            if (enable) {
                if let pollerAction = self.pollerAction {
                    self.polling = true;
                    self.poller.start(pollerAction);
                }
            }
            else {
                self.polling = false;
                self.poller.stop();
            }
        }

        public /*mutating*/ func poll(_ action: (@escaping () async -> Void)) {
            self.pollerAction = action;
            self.polling = true;
            self.poller.start(action);
        }

        public /*mutating*/ func update(from session: MultiPlayer.Session, select: Bool = false) {
            self.session = session.session;
            self.host = session.host;
            self.players = session.players;
            self.connected = session.connected;
            self.leaveable = session.leaveable;
            if (select) {
                self.sessions.select(self.session);
            }
        }

        public /*mutating*/ func update(from session: MultiPlayer.Session,
                                        info: Json?,
                                        sessions: [String]?,
                                        pingable: Bool,
                                        production: Bool,
                                        server: String,
                                        debug: Bool,
                                        chats: [MultiPlayer.ChatMessage]) {
            self.update(from: session);
            self.pingable = pingable;
            self.production = production;
            self.server = server;
            self.debug = debug;
            self.chats = chats;
            self.pollCount = self.poller.count;
            if let info: Json = info {
                self.info = info;
            }
            if let sessions: [String] = sessions {
                // self.sessions.update(sessions.reversed());
                var copy = self.sessions;
                copy.update(sessions.reversed());
                self.sessions = copy;
            }
            // self.sessionShort = self.sessions.shorten(self.session ?? Defaults.emptySetChar)
            self.xsessions = PrefixableList(sessions?.reversed())
        }

        public struct SessionList {

            private static      let shortLengthDefault: Int = 4;
            private             var list: [String] = [];
            public private(set) var listShort: [String] = [];
            public              var selected: String? { return self.list.first { $0.hasPrefix(self.selectedShort) }; }
            public              var selectedShort: String = "";
            private             var shortLength: Int = SessionList.shortLengthDefault;

            fileprivate init(_ sessions: [String] = []) {
                self.update(sessions);
            }

            public func contains(_ session: String?) -> Bool {
                return (session != nil) && self.list.contains(session!) ? true : false;
            }

            fileprivate mutating func select(_ session: String?) {
                if let session: String = session {
                    if (!self.list.contains(session)) {
                        // self.list.append(session);
                        var copy = list;
                        copy.append(session);
                        self.list = copy;
                    }
                    self.selectedShort = self.shorten(session);
                }
                else {
                    self.selectedShort = "";
                }
            }

            fileprivate mutating func update(_ sessions: [String]) {
                let changed: Bool = (sessions == self.list);
                self.list = sessions;
                (self.listShort, self.shortLength) = SessionList.shortenValues(sessions);
                if (self.selectedShort.isEmpty || changed) {
                    self.selectedShort = self.listShort.first ?? "";
                }
            }

            fileprivate func shorten(_ session: String?, fallback: String = "") -> String {
                if let session: String = session {
                    return String(session.prefix(self.shortLength));
                }
                return fallback;
            }

            // Returns the given array of strings, which is assumed to contain UNIQUE values,
            // where each value is truncated to the first, at mininum, the given minimum number
            // of characters; but if not, then the prefix length will be chosen such that the
            // result values will be unique. From ChatGPT wholesale.
            //
            private static func shortenValues(_ list: [String]) -> (list: [String], shortLength: Int) {
                guard !list.isEmpty else { return (list: [], shortLength: SessionList.shortLengthDefault) }
                var result = Array(repeating: "", count: list.count); var prefixLength = SessionList.shortLengthDefault;
                while (true) {
                    var seen = Set<String>(); var collision = false;
                    for (i, item) in list.enumerated() {
                        let prefix = String(item.prefix(prefixLength)); result[i] = prefix;
                        if (seen.contains(prefix)) { collision = true } else { seen.insert(prefix); }
                    }
                    if (!collision) { return (list: result, shortLength: prefixLength); } ; prefixLength += 1;
                }
            }
        }
    }
}
