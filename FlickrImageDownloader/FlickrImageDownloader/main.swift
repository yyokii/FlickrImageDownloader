//
//  main.swift
//  FlickrImageDownloader
//
//  Created by Higashihara Yoki on 2021/08/03.
//

import Combine
import Entity
import Foundation
import ImageDownloader

var cancellables = Set<AnyCancellable>()
let imageDownloader: ImageDownloader = ImageDownloaderImpl()

func run() {
    let arg = CommandLine.arguments
    let keyword = arg[1]
        
    imageDownloader.downloadImages(of: keyword)
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
                exit(EXIT_SUCCESS)
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

run()
