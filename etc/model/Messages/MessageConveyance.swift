import Foundation

public extension GameCenter {

    public struct MessageConveyance {

        public static func dispatch(messages: [Message]?, handler: MessageHandler) {
            if let messages: [Message] = messages {
                for message: Message in messages {
                    MessageConveyance.dispatch(message: message,
                                               ping: handler.handle,
                                               joinSession: handler.handle,
                                               joinedSession: handler.handle,
                                               leaveSession: handler.handle,
                                               updateSession: handler.handle);
                }
            }
        }
    
        private static func dispatch(message: Message?,
                                    ping: ((PingMessage) -> Void)? = nil,
                                    joinSession: ((JoinSessionMessage) -> Void)? = nil,
                                    joinedSession: ((JoinedSessionMessage) -> Void)? = nil,
                                    leaveSession: ((LeaveSessionMessage) -> Void)? = nil,
                                    updateSession: ((UpdateSessionMessage) -> Void)? = nil) {
            if let message: Message = message {
                switch message {
                    case let message as PingMessage: ping?(message);
                    case let message as JoinSessionMessage: joinSession?(message);
                    case let message as JoinedSessionMessage: joinedSession?(message);
                    case let message as LeaveSessionMessage: leaveSession?(message);
                    case let message as UpdateSessionMessage: updateSession?(message);
                    default: break;
                }
            }
        }
    }
}
