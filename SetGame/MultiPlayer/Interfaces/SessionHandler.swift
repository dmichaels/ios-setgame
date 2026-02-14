public extension MultiPlayer {

    public protocol SessionHandler: MessageHandler {
        var xsession: Session? { get set }
    }
}
