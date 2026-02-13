public extension MultiPlayer {

    // TODO
    // Rethink this in terms of the ONLY consumer being the Session (protocol) implementation.
    // If we do it skillfully we may be able to have only a single Session implementation that
    // uses HttpTransport for our (Python) server based approach, and maybe eventually we will
    // have a GameCenter based Transport that requires no (or minimal) changes to that Session
    // implementation; time will tell.
    //
    public protocol Transport: AnyObject {

        var  player: String { get }
        func setup();
        func release();
        func bindSession(to: String);
        func bindSessionTentative(to: String);

        func createAndHostSession(host: String, bind: Bool) async -> String?;
        func registerPlayerAndNotify(player: String, session: String?) async -> (player: String, host: String)?;
        func unregisterPlayerAndNotify(player: String, session: String?) async -> Bool;
        func setHostAndNotify(player: String, session: String?) async -> Bool;

        func sendMessage(_ message: MultiPlayer.Message, player: String, session: String?) async -> Bool;
        func sendHostMessage(_ message: MultiPlayer.Message, session: String?) async -> Bool;
        func sendHostMessage(_ message: MultiPlayer.Message, session: String?) -> Bool;
        func sendMessage(_ message: MultiPlayer.Message, player: String, session: String?) -> Bool;
    }
}
