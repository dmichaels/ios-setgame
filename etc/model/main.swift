print("Main module")

var table: Table = Table();
var transport: GameCenter.HttpTransport = GameCenter.HttpTransport(handler: table);
var session: GameCenter.HttpSession = GameCenter.HttpSession.instance(handler: table, transport: transport);
print("FROM SESSION.INSTANCE FUNCTION> \(ID.of(session))")
print("FROM SESSION.INSTANCE PROPERTY> \(ID.of(GameCenter.HttpSession.instance!))")
if await session.create() {
    print("CREATED SESSION> \(session.id) player: \(session.player)");
}

var transport2: GameCenter.HttpTransport = GameCenter.HttpTransport(handler: table);
var session2: GameCenter.HttpSession = GameCenter.HttpSession.instance(handler: table, transport: transport2);

/*
if await session2.join(session: session.id) {
    print("JOINED SESSION> session: \(session.id) player: \(session2.player)");
}
*/
session2.requestJoin(session: session.id);



for _ in 0..<100000000 {}
