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
    }
}
