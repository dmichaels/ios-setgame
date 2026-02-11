public protocol SessionHandler: GameCenter.MessageHandler {
    var  session: Session? { get set }
}
