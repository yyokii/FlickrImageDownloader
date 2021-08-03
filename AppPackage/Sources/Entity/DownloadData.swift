import Foundation

public struct DownloadData {
    public let destination: URL
    public let fileURL: URL
    public let fileName: String
    
    public init(destination: URL, fileURL: URL, fileName: String) {
        self.destination = destination
        self.fileURL = fileURL
        self.fileName = fileName
    }
}
