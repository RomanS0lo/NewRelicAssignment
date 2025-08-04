//
//  NetworkMonitorTests.swift
//  NewRelicTests
//
//  Created on 8/4/25.
//  Copyright © 2025. All rights reserved.
//

import XCTest
@testable import NewRelic

class NetworkMonitorTests: XCTestCase {
    
    var networkMonitor: NetworkMonitor!
    
    override func setUp() {
        super.setUp()
        // Create a fresh instance for testing
        networkMonitor = NetworkMonitor.shared
    }
    
    func testRecordResponseTime() {
        // Given
        let endpoint = "/test/endpoint"
        let duration: TimeInterval = 0.5
        
        // When
        networkMonitor.recordResponseTime(for: endpoint, duration: duration)
        
        // Allow time for async operation
        let expectation = XCTestExpectation(description: "Record response time")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let metrics = networkMonitor.getAllMetrics()
        XCTAssertTrue(metrics.contains { $0.endpoint == endpoint })
        
        if let metric = metrics.first(where: { $0.endpoint == endpoint }) {
            XCTAssertEqual(metric.averageTime, duration)
        }
    }
    
    func testAverageResponseTimeCalculation() {
        // Given
        let endpoint = "/breeds"
        let durations: [TimeInterval] = [0.1, 0.2, 0.3, 0.4, 0.5]
        let expectedAverage = 0.3 // (0.1 + 0.2 + 0.3 + 0.4 + 0.5) / 5
        
        // When
        for duration in durations {
            networkMonitor.recordResponseTime(for: endpoint, duration: duration)
        }
        
        // Allow time for async operations
        let expectation = XCTestExpectation(description: "Calculate average")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let metrics = networkMonitor.getAllMetrics()
        if let metric = metrics.first(where: { $0.endpoint == endpoint }) {
            XCTAssertEqual(metric.averageTime, expectedAverage, accuracy: 0.01)
        } else {
            XCTFail("Metric not found for endpoint")
        }
    }
    
    func testMultipleEndpoints() {
        // Given
        let endpoint1 = "/breeds"
        let endpoint2 = "/facts"
        
        // When
        networkMonitor.recordResponseTime(for: endpoint1, duration: 0.5)
        networkMonitor.recordResponseTime(for: endpoint2, duration: 1.0)
        
        // Allow time for async operations
        let expectation = XCTestExpectation(description: "Multiple endpoints")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let metrics = networkMonitor.getAllMetrics()
        XCTAssertEqual(metrics.count, 2)
        XCTAssertTrue(metrics.contains { $0.endpoint == endpoint1 })
        XCTAssertTrue(metrics.contains { $0.endpoint == endpoint2 })
    }
}
