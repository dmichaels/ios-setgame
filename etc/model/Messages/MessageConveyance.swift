import Foundation

public struct MessageConveyance {

    public static func dispatch(messages: [Message]?, handler: GameCenter.MessageHandler) {
        if let messages: [Message] = messages {
            for message: Message in messages {
                MessageConveyance.dispatch(message: message,
                                           ping: handler.handle,
                                           joinSession: handler.handle,
                                           joinedSession: handler.handle);
            }
        }
    }

    private static func dispatch(message: Message?,
                                ping: ((PingMessage) -> Void)? = nil,
                                joinSession: ((JoinSessionMessage) -> Void)? = nil,
                                joinedSession: ((JoinedSessionMessage) -> Void)? = nil) {
        if let message: Message = message {
            switch message {
                case let message as PingMessage: ping?(message);
                case let message as JoinSessionMessage: joinSession?(message);
                case let message as JoinedSessionMessage: joinedSession?(message);
                default: break;
            }
        }
    }
}
