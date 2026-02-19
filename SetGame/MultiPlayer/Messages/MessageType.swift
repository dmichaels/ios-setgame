public extension MultiPlayer {

    public enum MessageType: String, Codable {
        case ping;                 // host or non-host
        case pingAcknowledge;      // host or non-host
        case joinSession;          // non-host to host only
        case joinSessionConfirmed; // server (in response to join) to non-host only
        case leaveSession;         // non-host to host only
        case requestHostSession;   // non-host to host only
        case updateSession;        // host or non-host
        case newGame;              // host or non-host
        case setFound;             // host or non-host
        case setConfirmed;         // from host only
        case setMissed;           // from host only
    }
}

public extension MultiPlayer.SessionHandler {
    //
    // These session management related message handlers are defaulted so
    // that the main SessionHandler, i.e. Table in our case, does not have
    // to bother implementing these, since this should be of no concern there;
    // these are instead handled directly by the HttpSession implementation.
    //
    func handle(message: MultiPlayer.PingMessage) {}
    func handle(message: MultiPlayer.PingAcknowledgeMessage) {}
    func handle(message: MultiPlayer.JoinSessionMessage) {}
    func handle(message: MultiPlayer.JoinSessionConfirmedMessage) {}
    func handle(message: MultiPlayer.LeaveSessionMessage) {}
    func handle(message: MultiPlayer.RequestHostSessionMessage) {}
    func handle(message: MultiPlayer.UpdateSessionMessage) {}
    func handle(message: MultiPlayer.NewGameMessage) {}
    func handle(message: MultiPlayer.SetFoundMessage) {}
    func handle(message: MultiPlayer.SetConfirmedMessage) {}
    func handle(message: MultiPlayer.SetMissedMessage) {}
}
