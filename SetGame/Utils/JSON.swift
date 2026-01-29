import Foundation

public struct JSON {
    public static func format(data: Data) -> String {
        if let data = try? JSONSerialization.jsonObject(with: data),
           let pdata = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted]),
           let result = String(data: pdata, encoding: .utf8) {
            return result;
        }
        return "";
    }
}
