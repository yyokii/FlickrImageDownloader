//
//  APIClient.swift
//  FlickrImageDownloader
//
//  Created by Higashihara Yoki on 2021/08/03.
//

import Combine
import Entity
import Foundation

public protocol APIClient {
    func request<T: Decodable>(for url: URL) -> AnyPublisher<T, Error>
}

public struct APIClientImpl: APIClient {
    public init() {}
    
    public func request<T: Decodable>(for url: URL) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result in
                let decoder = JSONDecoder()
                guard let urlResponse = result.response as? HTTPURLResponse,
                      (200...299).contains(urlResponse.statusCode) else {
                    let apiError = try decoder.decode(FlickrAPIError.self, from: result.data)
                    throw apiError
                }
                return try decoder.decode(T.self, from: result.data)
            }
            .eraseToAnyPublisher()
    }
}
