import Foundation

print("Main module")

let args = CommandLine.arguments;
var sessionToJoin: String?

if (args.count > 1) {
    sessionToJoin = args[1];
}

let url: URL = URL.create("https://api.logicard.dmichaels.dev") // URL.create("http://127.0.0.1:8001")
var table: Table = Table()
let joinWait: Bool = true;
var pollTask: Task<Void, Never>? = nil;
let pollInterval: UInt64 = 2_000_000_000;

Task {

    if let sessionToJoin = sessionToJoin {
        let session: GameCenter.HttpSession = GameCenter.HttpSession(handler: table, url: url);
        if await session.join(session: sessionToJoin) {
            print("JOINED SESSION> \(session.session!) player: \(session.player) host: \(session.host!) hosting: \(session.hosting) players: \(session.players)")
        }
        poll(session: session);
    }
    else {
        let session: GameCenter.HttpSession = GameCenter.HttpSession(handler: table, url: url);
        if await session.create() {
            print("CREATED SESSION> \(session.session!) player: \(session.player) host: \(session.host!) hosting: \(session.hosting) players: \(session.players)")
        }
        poll(session: session);
    }

/*
    var sessionA: GameCenter.HttpSession = GameCenter.HttpSession(handler: table, url: url)
    print("SESSION-A> \(ID.of(sessionA)) player: \(sessionA.player) host: \(sessionA.host) hosting: \(sessionA.hosting) session: \(sessionA.session) players: \(sessionA.players)")
    if await sessionA.create() {
        print("CREATED HOSTED SESSION-A> \(sessionA.session) player: \(sessionA.player)  host: \(sessionA.host) hosting: \(sessionA.hosting) players: \(sessionA.players)")
    }
    else {
        print("ERROR CREATING SESSION-A> \(sessionA.session) player: \(sessionA.player)  host: \(sessionA.host) hosting: \(sessionA.hosting) players: \(sessionA.players)")
    }

    var sessionB: GameCenter.Session = GameCenter.HttpSession(
        handler: table,
        transport: { handler in GameCenter.HttpTransport(handler: handler, url: url) }
    )
    print("SESSION-B> \(ID.of(sessionB)) player: \(sessionB.player) host: \(sessionB.host) hosting: \(sessionB.hosting) session: \(sessionB.session) players: \(sessionB.players)")
    print("SESSION-B JOINING SESSION-B to SESSION-A \(joinWait ? "VIA MESSAGE WITH WAIT" : "VIA MESSAGE")>")
    if await sessionB.join(session: sessionA.session, wait: joinWait) {
        if (joinWait) {
            print("SESSION-B JOINED SESSION-A VIA MESSAGE WITH WAIT> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting) players: \(sessionB.players)")
        }
        else {
            print("SESSION-B SUBMITTED JOIN SESSION-A REQUEST> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting) players: \(sessionB.players)")
        }
    }
    else {
        print("SESSION-B ERROR JOINING SESSION-A> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting) players: \(sessionB.players)")
    }
    try? await Task.sleep(nanoseconds: 5_000_000_000);
    print("SESSION-B CHECKUP> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting) players: \(sessionB.players)")
    print("SESSION-A CHECKUP> \(sessionA.session) player: \(sessionA.player)  host: \(sessionA.host) hosting: \(sessionA.hosting) players: \(sessionA.players)")
*/

}

private func poll(session: GameCenter.Session) {
    guard pollTask == nil else { return }
    pollTask = Task {
        while (!Task.isCancelled) {
            print("POLL SESSION> \(session.session) player: \(session.player) host: \(session.host) hosting: \(session.hosting) players: \(session.players)")
            try? await Task.sleep(nanoseconds: pollInterval);
        }
    }
}

private func nopoll() {
    pollTask?.cancel();
    pollTask = nil;
}

dispatchMain();
