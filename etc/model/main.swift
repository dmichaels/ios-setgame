import Foundation

print("Main module")

// let url: URL = URL.create("https://api.logicard.dmichaels.dev")
let url: URL = URL.create("http://127.0.0.1:8001")
var table: Table = Table()
var sessionA: GameCenter.HttpSession = GameCenter.HttpSession(handler: table, url: url)

print("SESSION-A> \(ID.of(sessionA))")

Task {
    if await sessionA.create() {
        print("CREATED SESSION> \(sessionA.id) player: \(sessionA.player)")
    }

    var sessionB: GameCenter.Session = GameCenter.HttpSession(
        handler: table,
        transport: { handler in GameCenter.HttpTransport(handler: handler, url: url) }
    )
    print("SESSION-B> \(ID.of(sessionB))")

    await sessionB.join(session: sessionA.id)
}

dispatchMain() // 🔒 This keeps the app alive forever.
