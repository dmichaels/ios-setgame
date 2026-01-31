import Foundation

public extension URL {

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

    public func request(_ path: String?..., method: String? = nil, data: Data? = nil) -> URLRequest {
        return self.request(path, method: method, data: data);
    }

    public func get(_ path: [String?], status: Int? = 200) async -> Data? {
        if let response = try? await URLSession.shared.data(from: self.append(path)) {
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

    public func get(_ path: String?..., status: Int? = 200) async -> Data? {
        return await self.get(path, status: status);
    }

    public func get<T: Decodable>(_ path: [String?], as type: T.Type, status: Int? = 200) async -> T? {
        if let response = await self.get(path, status: status) {
            if let response = URL.decode(data: response, as: type) {
                return response;
            }
        }
        return nil;
    }

    public func get<T: Decodable>(_ path: String?..., as type: T.Type, status: Int? = 200) async -> T? {
        return await self.get(path, as: type, status: status);
    }

    public func get(_ path: [String?], as type: [String: Any].Type, status: Int? = 200) async -> [String: Any]? {
        if let response = await self.get(path, status: status) {
            return try? JSONSerialization.jsonObject(with: response) as? [String: Any];
        }
        return nil;
    }

    public func get(_ path: String?..., as type: [String: Any].Type, status: Int? = 200) async -> [String: Any]? {
        await self.get(path, as: type, status: status);
    }

    public func request(_ path: [String?], method: String? = nil, data: Data? = nil) -> URLRequest {
	    var request = URLRequest(url: self.append(path));
        if let method: String = method { request.httpMethod = method; }
        if let data: Data = data { 
            request.setValue("application/json", forHTTPHeaderField: "Content-Type");
            request.httpBody = data;
        }
        return request;
    }

    public func post(_ path: [String?], data: Data? = nil, status: Int? = nil) async -> Data? {
        let request: URLRequest = self.request(path, method: "POST", data: data);
        if let response = try? await URLSession.shared.data(for: request) {
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

    public func post(_ path: String?..., data: Data? = nil, status: Int? = nil) async -> Data? {
        return await self.post(path, data: data, status: status);
    }

    public func post<T: Decodable>(_ path: [String?], data: Data? = nil, as type: T.Type, status: Int? = nil) async -> T? {
        if let response = try? await self.post(path, data: data, status: status) {
            return URL.decode(data: response, as: type);
        }
        return nil;
    }

    public func post<T: Decodable>(_ path: String?..., data: Data? = nil, as type: T.Type, status: Int? = nil) async -> T? {
        return await self.post(path, data: data, as: type, status: status);
    }

    private static func decode<T: Decodable>(data: Data, as type: T.Type) -> T? {
        return try? JSONDecoder().decode(type, from: data);
    }

    public func old_request(_ path: String? = nil, method: String? = nil) -> URLRequest { // TODO DELETE USE ABOVE
	    var request = URLRequest(url: (path != nil) ? self.append(path!) : self);
        if let method: String = method {
            request.httpMethod = method;
        }
        return request;
    }
}
