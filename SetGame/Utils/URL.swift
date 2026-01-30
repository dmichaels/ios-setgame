import Foundation

public extension URL {

    public func append(_ path: String) -> URL {
        return URL(string: path, relativeTo: self)!;
    }

    public func request(_ path: String, method: String?) -> URLRequest {
	    var request = URLRequest(url: self.append(path));
        if let method: String = method {
            request.httpMethod = method;
        }
        return request;
    }
}
