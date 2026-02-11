import Foundation

public protocol Message: Codable {
    var type: MessageType { get }
    var  json: [String: Any]? { get };
}

public extension Message {
    public var json: [String: Any]? {
        if let data = try? JSONEncoder().encode(self),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json;
        }
        return nil;
    }
}

public struct MessageConversion {

    public static func toMessages(data: Data?) -> [Message]? {
        if let data: Data = data,
           let array: [[String: Any]] = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            var messages: [Message] = []; messages.reserveCapacity(array.count);
            let decoder: JSONDecoder = JSONDecoder();
            for object: [String: Any] in array {
                if JSONSerialization.isValidJSONObject(object),
                   let item: Data = try? JSONSerialization.data(withJSONObject: object) {
                    if let message: Message = MessageConversion.toMessage(data: item) {
                        messages.append(message);
                    }
                 }
            }
            return messages;
        }
        return nil;
    }

    private static func toMessage(data: Data?) -> Message? {
        struct MessageEnvelope: Decodable { let type: MessageType; }
        if let data: Data = data,
        let envelope: MessageEnvelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) {
            switch envelope.type {
                case .ping:          return try? JSONDecoder().decode(PingMessage.self, from: data);
                case .joinSession:   return try? JSONDecoder().decode(JoinSessionMessage.self, from: data);
                case .joinedSession: return try? JSONDecoder().decode(JoinedSessionMessage.self, from: data);
            }
        }
        return nil;
    }

    // fileprivate static func toCards(_ codes: [String]) -> [TableCard] {
    //     return codes.compactMap { TableCard($0) };
    // }
}

public struct MessageConveyance {

    public static func dispatch(messages: [Message]?, handler: MessageHandler) {
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
