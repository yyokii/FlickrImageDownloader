//
//  URLSession+DownloadTaskPublisher.swift
//  FlickerImageDownloader
//
//  Created by Higashihara Yoki on 2021/08/02.
//

import Foundation
import Combine

/*
 Reference: https://stackoverflow.com/a/32322851/9015472
 
 Adapted from Apple's `DataTaskPublisher` at: https://github.com/apple/swift/blob/88b093e9d77d6201935a2c2fb13f27d961836777/stdlib/public/Darwin/Foundation/Publishers%2BURLSession.swift
 */
extension URLSession {
    /// Returns a publisher that wraps a URL session download task for a given URL.
    ///
    /// The publisher publishes temporary when the task completes, or terminates if the task fails with an error.
    ///
    /// - Parameter url: The URL for which to create a download task.
    /// - Returns: A publisher that wraps a download task for the URL.
    public func downloadTaskPublisher(for url: URL) -> DownloadTaskPublisher {
        let request = URLRequest(url: url)
        return DownloadTaskPublisher(request: request, session: self)
    }

    public struct DownloadTaskPublisher: Publisher {
        public typealias Output = (location: URL, response: URLResponse)
        public typealias Failure = URLError

        public let request: URLRequest
        public let session: URLSession

        public init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            subscriber.receive(subscription: Inner(self, subscriber))
        }

        private typealias Parent = DownloadTaskPublisher
        private final class Inner<Downstream: Subscriber>: Subscription, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible
        where
            Downstream.Input == Parent.Output,
            Downstream.Failure == Parent.Failure
        {
            typealias Input = Downstream.Input
            typealias Failure = Downstream.Failure

            private let lock: NSLocking
            private var parent: Parent?               // GuardedBy(lock)
            private var downstream: Downstream?       // GuardedBy(lock)
            private var demand: Subscribers.Demand    // GuardedBy(lock)
            private var task: URLSessionDownloadTask! // GuardedBy(lock)
            var description: String { return "DownloadTaskPublisher" }
            var customMirror: Mirror {
                lock.lock()
                defer { lock.unlock() }
                return Mirror(self, children: [
                    "task": task as Any,
                    "downstream": downstream as Any,
                    "parent": parent as Any,
                    "demand": demand,
                ])
            }
            var playgroundDescription: Any { return description }

            init(_ parent: Parent, _ downstream: Downstream) {
                self.lock = NSLock()
                self.parent = parent
                self.downstream = downstream
                self.demand = .max(0)
            }

            // MARK: - Upward Signals
            func request(_ d: Subscribers.Demand) {
                precondition(d > 0, "Invalid request of zero demand")

                lock.lock()
                guard let p = parent else {
                    // We've already been cancelled so bail
                    lock.unlock()
                    return
                }

                // Avoid issues around `self` before init by setting up only once here
                if self.task == nil {
                    let task = p.session.downloadTask(
                        with: p.request,
                        completionHandler: handleResponse(location:response:error:)
                    )
                    self.task = task
                }

                self.demand += d
                let task = self.task!
                lock.unlock()

                task.resume()
            }

            private func handleResponse(location: URL?, response: URLResponse?, error: Error?) {
                lock.lock()
                guard demand > 0,
                      parent != nil,
                      let ds = downstream
                else {
                    lock.unlock()
                    return
                }

                parent = nil
                downstream = nil

                // We clear demand since this is a single shot shape
                demand = .max(0)
                task = nil
                lock.unlock()

                if let location = location, let response = response, error == nil {
                    _ = ds.receive((location, response))
                    ds.receive(completion: .finished)
                } else {
                    let urlError = error as? URLError ?? URLError(.unknown)
                    ds.receive(completion: .failure(urlError))
                }
            }

            func cancel() {
                lock.lock()
                guard parent != nil else {
                    lock.unlock()
                    return
                }
                parent = nil
                downstream = nil
                demand = .max(0)
                let task = self.task
                self.task = nil
                lock.unlock()
                task?.cancel()
            }
        }
    }
}
