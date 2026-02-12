import Foundation

print("Main module")

// let url: URL = URL.create("https://api.logicard.dmichaels.dev")
let url: URL = URL.create("http://127.0.0.1:8001")
var table: Table = Table()

let joinWait: Bool? = true;

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
    print("SESSION-B JOINING SESSION-B to SESSION-A \(joinWait == nil ? "DIRECTLY" : (joinWait == true ? "VIA MESSAGE WITH WAIT" : "VIA MESSAGE"))>")
    // if await sessionB.join(session: sessionA.session) {
    // if await sessionB.joinSession(sessionID: sessionA.session!) {
    // if await sessionB.join(session: sessionA.session) {
    if await sessionB.join(session: sessionA.session, wait: joinWait) {
        if (joinWait == nil) {
            print("SESSION-B JOINED SESSION-A DIRECTLY> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting)")
        }
        else if (joinWait == true) {
            print("SESSION-B JOINED SESSION-A VIA MESSAGE WITH WAIT> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting)")
        }
        else {
            print("SESSION-B SUBMITTED JOIN SESSION-A REQUEST> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting)")
        }
    }
    else {
        print("SESSION-B ERROR JOINING SESSION-A> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting)")
    }
    try? await Task.sleep(nanoseconds: 5_000_000_000);
    print("SESSION-B CHECKUP> \(sessionB.session) player: \(sessionB.player)  host: \(sessionB.host) hosting: \(sessionB.hosting)")

/*
    print("A")
    if let data: [Json] = await url.get("ECAB7022E77F4D0582A9704EF0826348", "receive", "591E", as: [Json].self, key: ".0turangalila") {
    // if let data: Json = await url.get("sessions", as: Json.self, key: ".0turangalila") {
        print("BiBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB")
        print(data)
    }
    print("C")
*/

}

dispatchMain() // 🔒 This keeps the app alive forever.
