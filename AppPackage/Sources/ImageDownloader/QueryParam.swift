import Foundation.NSURL

public enum QueryParam: String {
    case apiKey = "api_key"
    case extras
    case format
    case noJsonCallback = "nojsoncallback"
    case media
    case method
    case page
    case perPage = "per_page"
    case sort
    case safeSearch = "safe_search"
    case text
}

extension URLQueryItem {
    public init(queryParam: QueryParam, value: String?) {
        self.init(name: queryParam.rawValue, value: value)
    }
}
