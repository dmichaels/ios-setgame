print("Main module")

var table: Table = Table();
var transport: HttpTransport = HttpTransport(handler: table);
var session: Session = HttpSession.instance(handler: table, transport: transport);
print("FROM SESSION.INSTANCE FUNCTION: \(ObjectIdentifier(session))")
print("FROM SESSION.INSTANCE PROPERTY: \(ObjectIdentifier(HttpSession.instance!))")
await session.setup()

// session = HttpSession.instance(handler: table /*, transport: transport*/);
// print("FROM SESSION.INSTANCE FUNCTION: \(ObjectIdentifier(session))")
// print("FROM SESSION.INSTANCE PROPERTY: \(ObjectIdentifier(HttpSession.instance!))")

for _ in 0..<10000000 {
}
