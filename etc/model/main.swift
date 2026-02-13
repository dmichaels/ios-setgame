import Foundation

print("Logicard test module ...")

let args = CommandLine.arguments;
var (joinSession, leaveSessionAfter, hostSessionAfter): (String?, Int?, Int?) = parseArgs();

func parseArgs() -> (joinSession: String?, leaveSessionAfter: Int?, hostSessionAfter: Int?) {
    var joinSession: String?;
    var leaveSessionAfter: Int?;
    var hostSessionAfter: Int?;
    var args = CommandLine.arguments.dropFirst();
    while let arg = args.first {
        args = args.dropFirst()
        switch arg {
        case "--join":
            if let value = args.first {
                joinSession = value;
                args = args.dropFirst();
            }
        case "--leave":
            if let value = args.first, let valueInt = Int(value) {
                leaveSessionAfter = valueInt;
                args = args.dropFirst();
            }
        case "--host":
            if let value = args.first, let valueInt = Int(value) {
                hostSessionAfter = valueInt;
                args = args.dropFirst();
            }
        default:
            print("Unknown argument: \(arg)");
        }
    }

    return (joinSession, leaveSessionAfter, hostSessionAfter)
}

if let leaveSessionAfter = leaveSessionAfter { print("LEAVE SESSION AFTER: \(leaveSessionAfter)") }
if let hostSessionAfter = hostSessionAfter   { print("HOST SESSION AFTER: \(hostSessionAfter)") }

let url: URL = URL.create("http://127.0.0.1:8001") // URL.create("https://api.logicard.dmichaels.dev")
var table: Table = Table()
let joinWait: Bool = true;
var pollTask: Task<Void, Never>? = nil;
let pollInterval: UInt64 = 2_000_000_000;

Task {

    if let joinSession = joinSession {
        let session: GameCenter.HttpSession = GameCenter.HttpSession(handler: table, url: url);
        if await session.join(session: joinSession) {
            print("JOINED SESSION> \(session.session!) player: \(session.player) host: \(session.host!) hosting: \(session.hosting) players: \(session.players)")
        }
        poll(session: session);
        if let leaveSessionAfter = leaveSessionAfter {
            delayCall(seconds: leaveSessionAfter) {
                print("LEAVING SESSION> \(session.session!) player: \(session.player) host: \(session.host!) hosting: \(session.hosting) players: \(session.players)")
                if await session.leave() {
                    print("LEFT SESSION> \(session.session!) player: \(session.player) host: \(session.host!) hosting: \(session.hosting) players: \(session.players)")
                    nopoll();
                }
            }
        }
        if let hostSessionAfter = hostSessionAfter {
            delayCall(seconds: hostSessionAfter) {
                print("REQUEST HOST SESSION> \(session.session!) player: \(session.player) host: \(session.host!) hosting: \(session.hosting) players: \(session.players)")
                if await session.requestHost() {
                    print("REQUEST HOST SESSION ACCEPTED> \(session.session!) player: \(session.player) host: \(session.host!) hosting: \(session.hosting) players: \(session.players)")
                }
            }
        }
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
    print("START POLLING FOR> session: \(session.session) player: \(session.player)")
    pollTask = Task {
        while (!Task.isCancelled) {
            print("POLL SESSION> \(session.session) player: \(session.player) host: \(session.host) hosting: \(session.hosting) players: \(session.players)")
            try? await Task.sleep(nanoseconds: pollInterval);
        }
    }
}

private func nopoll() {
    print("STOP POLLING>")
    pollTask?.cancel();
    pollTask = nil;
}

private func delayCall(seconds: Int, perform: @escaping () async -> Void) {
    Task {
        let duration = UInt64(seconds * 1_000_000_000);
        try? await Task.sleep(nanoseconds: duration);
        await perform();
    }
}

dispatchMain();
