public extension MultiPlayer {

    public enum MessageType: String, Codable {
        case ping;
        case joinSession;
        case joinSessionConfirmed;
        case leaveSession;
        case requestHostSession;
        case updateSession;
    }
}

public extension MultiPlayer.SessionHandler {
    //
    // These session management related message handlers are defaulted so
    // that the main SessionHandler, i.e. Table in our case, does not have
    // to bother implementing these, since this should be of no concern there;
    // these are instead handled directly by the HttpSession implementation.
    //
    func handle(message: MultiPlayer.JoinSessionMessage) {}
    func handle(message: MultiPlayer.JoinSessionConfirmedMessage) {}
    func handle(message: MultiPlayer.LeaveSessionMessage) {}
    func handle(message: MultiPlayer.RequestHostSessionMessage) {}
    func handle(message: MultiPlayer.UpdateSessionMessage) {}
    func handle(message: MultiPlayer.PingMessage) {}
}
