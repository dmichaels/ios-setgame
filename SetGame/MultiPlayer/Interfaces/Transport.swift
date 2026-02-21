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

        // These are for internal dev/testing/debugging (DevPanelView) usage only!

        func sessions() async -> [String]?;
        func session(_ session: String?) async -> Json?;
        var  engaged: Bool { get }
        var  server: String { get }
        var  production: Bool { get set }
        func debug(enable: Bool?) async -> Bool;
        func ping() async -> Bool;
        func chats(sender: String, recipient: String) async -> [ChatMessage]?;
    }
}
