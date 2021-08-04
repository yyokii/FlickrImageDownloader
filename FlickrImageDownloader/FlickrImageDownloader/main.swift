import ArgumentParser
import Combine
import Entity
import Foundation
import ImageDownloader

struct FlickrImageDownloader: ParsableCommand {
    
    // Command line input
    @Argument(help: "Your API application key.")
     var apiKey: String
    @Argument(help: "A free text search.")
     var text: String
    @Option(name: .shortAndLong, help: "Number of photos to return per page.")
    var count: Int = 10
    @Option(name: .shortAndLong, help: "The page of results to return.")
    var page: Int = 1
    
    static var configuration = CommandConfiguration(
        commandName: "flcim",
        abstract: "Download image from flickr",
        discussion: """
        You can download images of any keyword using the flickr API ( https://www.flickr.com/services/api/ )
        """,
        version: "1.0.0",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    func run() throws {
        download(apiKey: apiKey, keyword: text, perPage: count, page: page)
    }
}

var cancellables = Set<AnyCancellable>()

func download(apiKey: String, keyword: String, perPage: Int, page: Int) {
    let imageDownloader: ImageDownloader = ImageDownloaderImpl(apiKey: apiKey)
    
    imageDownloader.downloadImages(of: keyword, perPage: perPage, page: page)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                if let apiError = error as? FlickrAPIError {
                    print(apiError.message)
                } else {
                    print("-----Error-----")
                    print(error)
                    print("-----Error LocalizedDescription-----")
                    print(error.localizedDescription)
                    print("----------")
                }
                exit(EXIT_FAILURE)
            case .finished:
                exit(EXIT_SUCCESS)
                break
            }
        }, receiveValue: { urls in
            print(urls)
        })
        .store(in: &cancellables)

    dispatchMain()
}

let command = FlickrImageDownloader()
FlickrImageDownloader.main()
