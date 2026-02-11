import Foundation

print("Main module")

let url: URL = URL.create("https://api.logicard.dmichaels.dev");
// let url: URL = URL.create("http://127.0.0.1:8001");
var table: Table = Table();
var session: GameCenter.HttpSession = GameCenter.HttpSession.instance (handler: table);
print("FROM SESSION.INSTANCE FUNCTION> \(ID.of(session))")
print("FROM SESSION.INSTANCE PROPERTY> \(ID.of(GameCenter.HttpSession.instance!))")
if await session.create() {
    print("CREATED SESSION> \(session.id) player: \(session.player)");
}

var session2: GameCenter.Session = GameCenter.HttpSession.instance(
    handler: table,
    transport: { handler in GameCenter.HttpTransport(handler: handler, url: url) }
);
//
// if await session2.join(session: session.id) {
//     print("JOINED SESSION> session: \(session.id) player: \(session2.player)");
// }
//
await session2.join(session: session.id);



for _ in 0..<100000000 {}














// OBSOLETE ...
// var transport: GameCenter.HttpTransport = GameCenter.HttpTransport(handler: table);
// var session: GameCenter.HttpSession = GameCenter.HttpSession.instance(handler: table, transport: transport);
/*
var session: GameCenter.HttpSession = GameCenter.HttpSession.instance (
    handler: table,
    transport: { handler in GameCenter.HttpTransport(handler: handler) }
);
*/
// var transport2: GameCenter.HttpTransport = GameCenter.HttpTransport(handler: table);
// var session2: GameCenter.HttpSession = GameCenter.HttpSession.instance(handler: table, transport: transport2);
