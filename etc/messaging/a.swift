
protocol MessageSender {
    func send();
}

protocol MessageHandler {
    func handle();
}

protocol SessionMessageHandler: MessageHandler, AnyObject {
    var  session: Session? { get set }
}

protocol Transport: MessageSender, MessageHandler {
    var player: String { get };
    func handle();
    func bind(to: MessageHandler);
}

protocol Session: MessageSender {
    var  host: String { get };
    func bind(to: SessionMessageHandler);
}

class HttpTransport: Transport {
    var player: String = "A";
    public var handler: MessageHandler?;
    func send() {}
    func handle() {}
    func bind(to handler: MessageHandler) {
        self.handler = handler;
    }
}

class HttpSession: Session {
    var  host: String { "somehost" }
    func send() {}
    func bind(to handler: SessionMessageHandler) {
        self.transport.bind(to: handler);
        handler.session = self;
    }
    private let transport: HttpTransport;
    init(transport: HttpTransport) {
        self.transport = transport;
    }
}

class Table: SessionMessageHandler {
    public var session: Session?;
    func handle() {}
    /*
    func work() {
        if let session: Session = session {
            if (session.host != "") {
            }
        }
    }
    */
}

var transport: HttpTransport = HttpTransport();
var session: Session = HttpSession(transport: transport);
