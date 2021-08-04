//
//  ImageDownloader.swift
//  FlickerImageDownloader
//
//  Created by Higashihara Yoki on 2021/07/31.
//

import APIClient
import Combine
import Entity
import Foundation
import Helper

public protocol ImageDownloader {
    var apiClient: APIClient { get }
    func downloadImages(of keyword: String, perPage: Int, page: Int) -> AnyPublisher<URL, Error>
}

public struct ImageDownloaderImpl: ImageDownloader {
    let apiKey: String
    public var apiClient: APIClient = APIClientImpl()
    var url = URL(string: "https://www.flickr.com/services/rest/")!
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func downloadImages(of keyword: String, perPage: Int = 10, page: Int = 1) -> AnyPublisher<URL, Error> {
        fetchDownloadFileData(of: keyword, perPage: perPage, page: page)
            .flatMap {
                downloadImages(datas: $0)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchDownloadFileData(of keyword: String, perPage: Int, page: Int) -> AnyPublisher<[DownloadData], Error> {
        
        let arrangedURL = arrangeURL(url: url,
                                     keyword: keyword,
                                     perPage: perPage,
                                     page: page)
        
        print("Request URL:  \(arrangedURL)")
        
        return apiClient.request(for: arrangedURL)
            .map { (data: SearchResult) -> [DownloadData]  in
                return data.photos.photo.compactMap {
                    if let urlString = $0.urlZ,
                       let url = URL(string: urlString) {
                        let fileName = $0.secret + ".jpg"
                        #warning("配置場所を動的に設定できるようにする")
                        let documentsURL = try!
                            FileManager.default.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: false)
                        return .init(
                            destination: documentsURL.appendingPathComponent(fileName),
                            fileURL: url,
                            fileName: fileName
                        )
                    } else {
                        return nil
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func arrangeURL(url: URL,
                            keyword: String,
                            perPage: Int,
                            page: Int) -> URL  {
        let queryItems: [URLQueryItem] = [
            .init(queryParam: .method, value: "flickr.photos.search"),
            .init(queryParam: .apiKey, value: apiKey),
            .init(queryParam: .text, value: keyword),
            .init(queryParam: .sort, value: "relevance"),
            .init(queryParam: .safeSearch, value: "1"),
            .init(queryParam: .media, value: "photos"),
            .init(queryParam: .extras, value: "url_z"),
            .init(queryParam: .page, value: String(page)),
            .init(queryParam: .perPage, value: String(perPage)),
            .init(queryParam: .format, value: "json"),
            .init(queryParam: .noJsonCallback, value: "1")
        ]
        
        let arrangedURL = url.addQueryItems(queryItems)!
        return arrangedURL
    }
    
    func downloadImages(datas: [DownloadData]) -> AnyPublisher<URL, Error> {
        return downloadsPublisher(for: datas, maxConcurrent: datas.count)
    }
    
    private func downloadsPublisher(for datas: [DownloadData], maxConcurrent: Int) -> AnyPublisher<URL, Error> {
        Publishers.Sequence(sequence: datas.map { downloadPublisher(for: $0) })
            .flatMap(maxPublishers: .max(maxConcurrent)) { $0 }
            .eraseToAnyPublisher()
    }
    
    private func downloadPublisher(for data: DownloadData) -> AnyPublisher<URL, Error> {
        URLSession.shared.downloadTaskPublisher(for: data.fileURL)
            .tryCompactMap {
                try FileManager.default.moveItem(at: $0.location, to: data.destination)
                return data.destination
            }
            .eraseToAnyPublisher()
    }
}
