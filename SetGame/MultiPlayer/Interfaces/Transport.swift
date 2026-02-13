public extension MultiPlayer {

    public protocol Transport: AnyObject {

        var  player: String { get }
        func engage();
        func disengage();
        func bindSession(to: String);
        func bindSessionTentative(to: String);

        func createAndHostSession(host: String, bind: Bool) async -> String?;
        func registerPlayerAndNotify(player: String, session: String?) async -> (player: String, host: String)?;
        func unregisterPlayerAndNotify(player: String, session: String?) async -> Bool;
        func setHostAndNotify(player: String, session: String?) async -> Bool;
        func destroySession(session: String?) async -> Bool;

        func sendMessage(_ message: MultiPlayer.Message, player: String, session: String?) async -> Bool;
        func sendHostMessage(_ message: MultiPlayer.Message, session: String?) async -> Bool;
        func sendHostMessage(_ message: MultiPlayer.Message, session: String?) -> Bool;
        func sendMessage(_ message: MultiPlayer.Message, player: String, session: String?) -> Bool;
    }
}
