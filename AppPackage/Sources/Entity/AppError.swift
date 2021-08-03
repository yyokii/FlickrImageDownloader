public enum AppError: Error {
    case invalidURL
    
    public var message: String {
        switch self {
        case .invalidURL:
            return "invalid URL structure"
        }
    }
}
