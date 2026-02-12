import Foundation

print("Main module")

let url: URL = URL.create("https://api.logicard.dmichaels.dev")
// let url: URL = URL.create("http://127.0.0.1:8001")
var table: Table = Table()

Task {

    var sessionA: GameCenter.HttpSession = GameCenter.HttpSession(handler: table, url: url)
    print("SESSION-A> \(ID.of(sessionA)) player: \(sessionA.player) host: \(sessionA.host) hosting: \(sessionA.hosting) session: \(sessionA.session)")
    if await sessionA.create() {
        print("CREATED SESSION-A> \(sessionA.session) player: \(sessionA.player)  host: \(sessionA.host) hosting: \(sessionA.hosting)")
    }
    else {
        print("ERROR CREATING SESSION-A> \(sessionA.session) player: \(sessionA.player)  host: \(sessionA.host) hosting: \(sessionA.hosting)")
    }

    var sessionB: GameCenter.Session = GameCenter.HttpSession(
        handler: table,
        transport: { handler in GameCenter.HttpTransport(handler: handler, url: url) }
    )
    print("SESSION-B> \(ID.of(sessionB)) player: \(sessionB.player) host: \(sessionB.host) hosting: \(sessionB.hosting) session: \(sessionB.session)")
    print("JOINING SESSION-B to SESSION-A")
    // if await sessionB.join(session: sessionA.session) {
    // if await sessionB.joinSession(sessionID: sessionA.session!) {
    // if await sessionB.join(session: sessionA.session) {
    if await sessionB.join(session: sessionA.session, direct: true, wait: false) {
        print("JOINED SESSION-B> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting)")
    }
    else {
        print("ERROR JOINING SESSION-B> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting)")
    }
    try? await Task.sleep(nanoseconds: 5_000_000_000);
    print("CHECK ON SESSION-B> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting)")
}

dispatchMain() // 🔒 This keeps the app alive forever.
