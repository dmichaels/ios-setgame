import Foundation

public extension MultiPlayer {

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
                    case .ping:                 return try? JSONDecoder().decode(PingMessage.self, from: data);
                    case .pingAcknowledge:      return try? JSONDecoder().decode(PingAcknowledgeMessage.self, from: data);
                    case .joinSession:          return try? JSONDecoder().decode(JoinSessionMessage.self, from: data);
                    case .joinSessionConfirmed: return try? JSONDecoder().decode(JoinSessionConfirmedMessage.self, from: data);
                    case .leaveSession:         return try? JSONDecoder().decode(LeaveSessionMessage.self, from: data);
                    case .requestHostSession:   return try? JSONDecoder().decode(RequestHostSessionMessage.self, from: data);
                    case .updateSession:        return try? JSONDecoder().decode(UpdateSessionMessage.self, from: data);
                    case .newGame:              return try? JSONDecoder().decode(NewGameMessage.self, from: data);
                    case .setFound:             return try? JSONDecoder().decode(SetFoundMessage.self, from: data);
                    case .setConfirmed:         return try? JSONDecoder().decode(SetConfirmedMessage.self, from: data);
                    case .setMissed:            return try? JSONDecoder().decode(SetMissedMessage.self, from: data);
                    case .chat:                 return try? JSONDecoder().decode(ChatMessage.self, from: data);
                }
            }
            return nil;
        }

        public static func toMessage(json: Json) -> Message? {
            if JSONSerialization.isValidJSONObject(json),
               let data: Data = try? JSONSerialization.data(withJSONObject: json) {
                if let message: Message = MessageConversion.toMessage(data: data) {
                    return message;
                }
             }
             return nil;
        }

        public static func toCards(_ codes: [String]) -> [TableCard] {
            return codes.compactMap { TableCard($0) };
        }
    }
}
