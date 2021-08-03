import Foundation.NSURL

extension URL {
    func addQueryItem(name: String,  value: String?) -> URL? {
        return self.addQueryItems([URLQueryItem(name: name, value: value)])
    }

    public func addQueryItems(_ queryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true ) else {
            return nil
        }
        components.queryItems = queryItems + (components.queryItems ?? [])
        return components.url
    }
}
