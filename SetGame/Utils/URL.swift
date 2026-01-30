import Foundation
import SwiftUI

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

    public func get(_ path: [String?]) async -> Data? {
        if let response = try? await URLSession.shared.data(from: self.append(path)) {
            return response.0;
        }
        return nil;
    }

    public func get(_ path: String?...) async -> Data? {
        return await self.get(path);
    }

    public func get<T: Decodable>(_ path: [String?], as type: T.Type) async -> T? {
        if let response = try? await URLSession.shared.data(from: self.append(path)) {
            if let response = try? JSONDecoder().decode(type, from: response.0) {
                return response;
            }
        }
        return nil;
    }

    public func get<T: Decodable>(_ path: String?..., as type: T.Type) async -> T? {
        return await self.get<T>(path, as: type);
    }

    public func get(_ path: [String?], as type: [String: Any].Type) async -> [String: Any]? {
        if let response = try? await URLSession.shared.data(from: self.append(path)) {
            return try? JSONSerialization.jsonObject(with: response.0) as? [String: Any];
        }
        return nil;
    }

    public func get(_ path: String?..., as type: [String: Any].Type) async -> [String: Any]? {
        await self.get(path, as: type);
    }

    public func request(_ path: String? = nil, method: String? = nil) -> URLRequest {
	    var request = URLRequest(url: (path != nil) ? self.append(path!) : self);
        if let method: String = method {
            request.httpMethod = method;
        }
        return request;
    }
}
