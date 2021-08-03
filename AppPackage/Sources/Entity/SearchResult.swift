public struct SearchResult: Codable {
    public let photos: Photos
    public let stat: String
}

public struct Photos: Codable {
    public let page: Int
    public let pages: Int
    public let perpage: Int
    public let total: Int
    public let photo: [Photo]
}

public struct Photo: Codable {
    public let secret: String
    public let urlZ: String?
    
    enum CodingKeys: String, CodingKey {
        case secret
        case urlZ = "url_z"
    }
}
