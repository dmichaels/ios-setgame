print("Main module")

var table: Table = Table();
var transport: HttpTransport = HttpTransport(handler: table);
var session: HttpSession = HttpSession.instance(handler: table, transport: transport);
print("FROM SESSION.INSTANCE FUNCTION> \(ID.of(session))")
print("FROM SESSION.INSTANCE PROPERTY> \(ID.of(HttpSession.instance!))")
if await session.create() {
    print("CREATED SESSION> \(session.id) player: \(session.player)");
}

var transport2: HttpTransport = HttpTransport(handler: table);
var session2: HttpSession = HttpSession.instance(handler: table, transport: transport2);

if await session2.join(session: session.id) {
    print("JOINED SESSION> session: \(session.id) player: \(session2.player)");
}




for _ in 0..<10000000 {}
