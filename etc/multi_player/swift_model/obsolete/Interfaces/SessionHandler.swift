public extension MultiPlayer {

    public protocol SessionHandler: MessageHandler {
        var  session: Session? { get set }
    }
}
