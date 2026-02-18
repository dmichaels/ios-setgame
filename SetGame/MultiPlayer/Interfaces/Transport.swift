public extension MultiPlayer {

    public protocol Transport: AnyObject {

        var  player: String { get }
        func engage();
        func disengage();
        func bind(to session: String);
        func bindTentative(to session: String);

        func create(host: String, bind: Bool) async -> String?;
        func register(player: String, session: String?) async -> (player: String, host: String)?;
        func unregister(player: String, session: String?) async -> Bool;
        func requestHost(player: String, session: String?) async -> Bool;
        func destroySession(session: String?) async -> Bool;
        func send(message: Message, player: String, session: String?) async -> Bool;
        func sendHost(message: Message, session: String?) async -> Bool;

        // For internal dev/testing (DevPanel) usage only!

        func retrieveSessions() async -> [String]?;
        func sessionInfo(session: String?) async -> Json?;
        var  engaged: Bool { get }
        var  server: String { get }
        func ping() async -> Bool;
        var  production: Bool { get set }
        var  debug: Bool { get async }
        func debug(enable: Bool) async;
    }
}
