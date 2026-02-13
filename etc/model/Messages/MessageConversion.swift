import Foundation

public extension GameCenter {

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
                    case .joinSessionConfirmed: return try? JSONDecoder().decode(JoinSessionConfirmedMessage.self, from: data);
                    case .leaveSession: return try? JSONDecoder().decode(LeaveSessionMessage.self, from: data);
                    case .updateSession: return try? JSONDecoder().decode(UpdateSessionMessage.self, from: data);
                }
            }
            return nil;
        }

        fileprivate static func toCards(_ codes: [String]) -> [TableCard] {
            return codes.compactMap { TableCard($0) };
        }
    }
}
