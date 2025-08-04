//
//  NetworkMonitor.swift
//  NewRelic
//
//  Created on 8/4/25.
//  Copyright © 2025. All rights reserved.
//

import Foundation

class NetworkMonitor: NSObject {
    static let shared = NetworkMonitor()
    
    private var apiMetrics: [String: [TimeInterval]] = [:]
    private let metricsQueue = DispatchQueue(label: "com.newrelic.metrics", attributes: .concurrent)
    
    private override init() {
        super.init()
    }
    
    func recordResponseTime(for endpoint: String, duration: TimeInterval) {
        metricsQueue.async(flags: .barrier) {
            if self.apiMetrics[endpoint] == nil {
                self.apiMetrics[endpoint] = []
            }
            self.apiMetrics[endpoint]?.append(duration)
        }
    }
    
    func getAverageResponseTime(for endpoint: String) -> TimeInterval? {
        metricsQueue.sync {
            guard let times = apiMetrics[endpoint], !times.isEmpty else { return nil }
            let sum = times.reduce(0, +)
            return sum / Double(times.count)
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
    
    func clearMetrics() {
        metricsQueue.async(flags: .barrier) {
            self.apiMetrics.removeAll()
        }
    }
}
