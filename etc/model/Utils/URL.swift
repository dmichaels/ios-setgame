import Foundation

public typealias Json = [String: Any];

public extension URL {

    public static func create(_ url: String) -> URL {
        return URL(string: url)!
    }

    public var value: String { self.absoluteString }

    // Simple URL construction/append methods.

    public func append(_ components: [String?]) -> URL {
        var result: URL = self;
        for component in components {
            if let path = component?.trimmingCharacters(in: .whitespacesAndNewlines), !path.isEmpty {
                result.appendPathComponent(path);
            }
        }
        return result
    }

    public func append(_ components: String?...) -> URL {
        return self.append(components)
    }

    // Request methods.

    public func request(_ path: [String?], method: String? = nil, data: Data? = nil, key: String? = nil) -> URLRequest {
	    var request = URLRequest(url: self.append(path));
        if let method: String = method {
            request.httpMethod = method;
        }
        if let data: Data = data { 
            request.setValue("application/json", forHTTPHeaderField: "Content-Type");
            request.httpBody = data;
        }
        if let key: String = key {
            request.setValue(key, forHTTPHeaderField: "X-API-Key");
        }
        return request;
    }

    public func request(_ path: String?..., method: String? = nil, data: Data? = nil, key: String? = nil) -> URLRequest {
        return self.request(path, method: method, data: data, key: key);
    }

    // GET methods.

    public func get(_ path: [String?],
                      status: Int? = 200, key: String? = nil) async -> Data? {
        return await self.exec(path, method: nil, data: nil, status: status, key: key);
    }

    public func get(_ path: String?...,
                      status: Int? = 200, key: String? = nil) async -> Data? {
        return await self.exec(path, method: nil, data: nil, status: status, key: key);
    }

    public func get<T: Decodable>(_ path: [String?],
                                    as type: T.Type,
                                    status: Int? = 200, key: String? = nil) async -> T? {
        return await self.exec(path, method: nil, data: nil, as: type, status: status, key: key);
    }

    public func get<T: Decodable>(_ path: String?...,
                                    as type: T.Type,
                                    status: Int? = 200, key: String? = nil) async -> T? {
        return await self.exec(path, method: nil, data: nil, as: type, status: status, key: key);
    }

    public func get(_ path: [String?],
                      as type: Json.Type,
                      status: Int? = 200, key: String? = nil) async -> Json? {
        return await self.exec(path, method: nil, data: nil, as: type, status: status, key: key);
    }

    public func get(_ path: String?...,
                      as type: Json.Type,
                      status: Int? = 200, key: String? = nil) async -> Json? {
        await self.get(path, as: type, status: status, key: key);
    }

    // POST methods.

    public func post(_ path: [String?], data: Data? = nil,
                       status: Int? = nil, key: String? = nil) async -> Data? {
        return await self.exec(path, method: "POST", data: data, status: status, key: key);
    }

    public func post(_ path: String?..., data: Data? = nil,
                       status: Int? = nil, key: String? = nil) async -> Data? {
        return await self.exec(path, method: "POST", data: data, status: status, key: key);
    }

    public func post<T: Decodable>(_ path: [String?], data: Data? = nil,
                                     as type: T.Type,
                                     status: Int? = nil, key: String? = nil) async -> T? {
        return await self.exec(path, method: "POST", data: data, as: type, status: status, key: key);
    }

    public func post<T: Decodable>(_ path: String?..., data: Data? = nil,
                                     as type: T.Type,
                                     status: Int? = nil, key: String? = nil) async -> T? {
        return await self.exec(path, method: "POST", data: data, as: type, status: status, key: key);
    }

    public func post(_ path: [String?], data: Data? = nil,
                       as type: Json.Type,
                       status: Int? = nil, key: String? = nil) async -> Json? {
        return await self.exec(path, method: "POST", data: data, as: type, status: status, key: key);
    }

    public func post(_ path: String?..., data: Data? = nil,
                       as type: Json.Type,
                       status: Int? = nil, key: String? = nil) async -> Json? {
        return await self.exec(path, method: "POST", data: data, as: type, status: status, key: key);
    }

    public func post(_ path: String?..., data: Json,
                       as type: Json.Type,
                       status: Int? = nil, key: String? = nil) async -> Json? {
        return await self.exec(path, method: "POST", data: data, as: type, status: status, key: key);
    }

    // POST fire-and-forget (not async) methods (the ones without an "as" type argument).

    public func post(_ path: [String?], data: Data? = nil, key: String? = nil) -> Bool {
        return self.execfaf(path, method: "POST", data: data, key: key);
    }

    public func post(_ path: String?..., data: Data? = nil, key: String? = nil) -> Bool {
        return self.execfaf(path, method: "POST", data: data, key: key);
    }

    // Note that currently only POST fire-and-forget methods support
    // JSON (i.e. [String: Any]) for the data body/payload type;
    // doing the other POST methods would double the number.

    public func post(_ path: [String?], data: Json, key: String? = nil) -> Bool {
        return self.execfaf(path, method: "POST", data: data, key: key);
    }

    public func post(_ path: String?..., data: Json, key: String? = nil) -> Bool {
        return self.execfaf(path, data: data, key: key);
    }

    // Implementation methods.

    private func exec(_ path: [String?], method: String? = nil,
                        data: Data? = nil,
                        status: Int? = nil, key: String? = nil) async -> Data? {
        if let response = try? await URLSession.shared.data(for: self.request(path, method: method, data: data, key: key)) {
            if let status: Int = status {
        		guard let response = response.1 as? HTTPURLResponse,
                          response.statusCode == status else {
                    return nil;
                }
            }
            return response.0;
        }
        return nil;
    }

    private func exec<T: Decodable>(_ path: [String?], method: String? = nil,
                                      data: Data? = nil,
                                      as type: T.Type,
                                      status: Int? = nil, key: String? = nil) async -> T? {
        if let response = await self.exec(path, method: method, data: data, status: status, key: key) {
            if let response = try? JSONDecoder().decode(type, from: response) {
                return response;
            }
        }
        return nil;
    }

    private func exec(_ path: [String?], method: String? = nil,
                        data: Data? = nil,
                        as type: Json.Type,
                        status: Int? = nil, key: String? = nil) async -> Json? {
        if let response = await self.exec(path, method: method, data: data, status: status, key: key) {
            return try? JSONSerialization.jsonObject(with: response) as? Json;
        }
        return nil;
    }

    private func exec(_ path: [String?], method: String? = nil,
                        data: Json,
                        as type: Json.Type,
                        status: Int? = nil, key: String? = nil) async -> Json? {
        if let data: Data = try? JSONSerialization.data(withJSONObject: data) {
            if let response = await self.exec(path, method: method, data: data, status: status, key: key) {
                return try? JSONSerialization.jsonObject(with: response) as? Json;
            }
        }
        return nil;
    }

    // Implementation methods for first-and-forget.

    private func execfaf(_ path: [String?], method: String? = nil, data: Data? = nil, key: String? = nil) -> Bool {
        URLSession.shared.dataTask(with: self.request(path, method: method, data: data, key: key)).resume();
        return true;
    }

    private func execfaf(_ path: [String?], method: String? = nil, data: Json, key: String? = nil) -> Bool {
        if let data: Data = try? JSONSerialization.data(withJSONObject: data) {
            return self.execfaf(path, method: "POST", data: data, key: key);
        }
        return false;
    }
}
