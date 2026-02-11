import Foundation

print("Main module")

let url: URL = URL.create("https://api.logicard.dmichaels.dev")
var table: Table = Table()
var session: GameCenter.HttpSession = GameCenter.HttpSession.instance(handler: table)

print("FROM SESSION.INSTANCE FUNCTION> \(ID.of(session))")
print("FROM SESSION.INSTANCE PROPERTY> \(ID.of(GameCenter.HttpSession.instance!))")

Task {
    if await session.create() {
        print("CREATED SESSION> \(session.id) player: \(session.player)")
    }

    var session2: GameCenter.Session = GameCenter.HttpSession.instance(
        handler: table,
        transport: { handler in GameCenter.HttpTransport(handler: handler, url: url) }
    )

    await session2.join(session: session.id)
}

dispatchMain() // 🔒 This keeps the app alive forever.
