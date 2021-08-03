public struct FlickrAPIError: Error, Codable {
    public let stat: String
    public let code: String
    public let message: String
}
