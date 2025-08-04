//
//  CatFetcher.swift
//  NewRelic
//
//  Created by newrelic on 8/16/20.
//  Copyright © 2020 newrelic. All rights reserved.
//

import Foundation

enum CatFetchError: Error {
    case networkError(Error)
    case noData
    case decodingError
}

// NetworkMonitor implementation
class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private var apiMetrics: [String: [TimeInterval]] = [:]
    private let metricsQueue = DispatchQueue(label: "com.newrelic.metrics", attributes: .concurrent)
    
    private init() {}
    
    func recordResponseTime(for endpoint: String, duration: TimeInterval) {
        metricsQueue.async(flags: .barrier) {
            if self.apiMetrics[endpoint] == nil {
                self.apiMetrics[endpoint] = []
            }
            self.apiMetrics[endpoint]?.append(duration)
        }
    }
    
    func getAllMetrics() -> [(endpoint: String, averageTime: TimeInterval)] {
        metricsQueue.sync {
            apiMetrics.compactMap { (key, values) in
                guard !values.isEmpty else { return nil }
                let average = values.reduce(0, +) / Double(values.count)
                return (endpoint: key, averageTime: average)
            }
        }
    }
}

class CatFetcher: NSObject {
    
    static let shared = CatFetcher()
    var urlSession: URLSession?

    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        self.urlSession = URLSession(configuration: configuration)
    }
    private func buildCatFactRequest(perPage: Int, page: Int) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "catfact.ninja"
        components.path = "/breeds"
        components.queryItems = [
            URLQueryItem(name: "limit", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        let url = components.url!
        let request = URLRequest(url: url)
        return request
    }
    /// Fetches the list of CatDetails.
    ///
    /// - Parameters:
    ///   - perPage:  How many results per page
    ///   - page:     The page of the partial results
    ///   - queue:    The `DispatchQueue` on which the `callback` is called. Default is
    ///               `DispatchQueue.main`.
    ///   - callback: The callback that will be invoked with the list of places or an empty Array in
    ///               case of an error.
    func loadCats(perPage: Int, page: Int, queue: DispatchQueue = .main, callback: @escaping (Result<CatResult, CatFetchError>) -> Void) {
        
let request = buildCatFactRequest(perPage: perPage, page: page)

        let startTime = Date()  // Start timing the request        
        let task = urlSession?.dataTask(with: request) { data, response, err in
            let endTime = Date()  // End timing the request
            let duration = endTime.timeIntervalSince(startTime)
            NetworkMonitor.shared.recordResponseTime(for: "/breeds (page: \(page))", duration: duration)

            queue.async {
                if let error = err {
                    callback(.failure(.networkError(error)))
                    return
                }
                
                guard let data = data else {
                    callback(.failure(.noData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CatResult.self, from: data)
                    callback(.success(result))
                } catch {
                    callback(.failure(.decodingError))
                }
            }
        }
        
        task?.resume()
    }
}

