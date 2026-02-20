import Foundation

public extension MultiPlayer {

    public struct MessageConveyance {

        public static func dispatch(messages: [Message]?, handler: MessageHandler) {
            if let messages: [Message] = messages {
                for message: Message in messages {
                    MessageConveyance.dispatch(message: message,
                                               ping: handler.handle,
                                               pingAcknowledge: handler.handle,
                                               joinSession: handler.handle,
                                               joinSessionConfirmed: handler.handle,
                                               leaveSession: handler.handle,
                                               requestHostSession: handler.handle,
                                               updateSession: handler.handle,
                                               newGame: handler.handle,
                                               setFound: handler.handle,
                                               setConfirmed: handler.handle,
                                               setMissed: handler.handle,
                                               chat: handler.handle);
                }
            }
        }
    
        private static func dispatch(message: Message?,
                                    ping: ((PingMessage) -> Void)? = nil,
                                    pingAcknowledge: ((PingAcknowledgeMessage) -> Void)? = nil,
                                    joinSession: ((JoinSessionMessage) -> Void)? = nil,
                                    joinSessionConfirmed: ((JoinSessionConfirmedMessage) -> Void)? = nil,
                                    leaveSession: ((LeaveSessionMessage) -> Void)? = nil,
                                    requestHostSession: ((RequestHostSessionMessage) -> Void)? = nil,
                                    updateSession: ((UpdateSessionMessage) -> Void)? = nil,
                                    newGame: ((NewGameMessage) -> Void)? = nil,
                                    setFound: ((SetFoundMessage) -> Void)? = nil,
                                    setConfirmed: ((SetConfirmedMessage) -> Void)? = nil,
                                    setMissed: ((SetMissedMessage) -> Void)? = nil,
                                    chat: ((ChatMessage) -> Void)? = nil) {
            if let message: Message = message {
                switch message {
                    case let message as PingMessage: ping?(message);
                    case let message as PingAcknowledgeMessage: pingAcknowledge?(message);
                    case let message as JoinSessionMessage: joinSession?(message);
                    case let message as JoinSessionConfirmedMessage: joinSessionConfirmed?(message);
                    case let message as LeaveSessionMessage: leaveSession?(message);
                    case let message as RequestHostSessionMessage: requestHostSession?(message);
                    case let message as UpdateSessionMessage: updateSession?(message);
                    case let message as NewGameMessage: newGame?(message);
                    case let message as SetFoundMessage: setFound?(message);
                    case let message as SetConfirmedMessage: setConfirmed?(message);
                    case let message as SetMissedMessage: setMissed?(message);
                    case let message as ChatMessage: chat?(message);
                    default: break;
                }
            }
        }
    }
}
