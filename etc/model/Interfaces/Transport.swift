public protocol Transport: MessageHandler {
    var  player: String { get }
    func setup();
    func release();
}
