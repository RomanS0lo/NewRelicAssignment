//
//  CatFetcherTests.swift
//  NewRelicTests
//
//  Created on 8/4/25.
//  Copyright © 2025. All rights reserved.
//

import XCTest
@testable import NewRelic

class MockURLSession: URLSession {
    var mockData: Data?
    var mockError: Error?
    var mockResponse: URLResponse?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockURLSessionDataTask()
        task.completionHandler = {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
        return task
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    var completionHandler: (() -> Void)?
    
    override func resume() {
        completionHandler?()
    }
}

class CatFetcherTests: XCTestCase {
    
    var catFetcher: CatFetcher!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        catFetcher = CatFetcher.shared
        mockSession = MockURLSession()
        catFetcher.urlSession = mockSession
    }
    
    override func tearDown() {
        catFetcher = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testLoadCatsSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Load cats successfully")
        let mockCatData = """
        {
            "data": [
                {
                    "breed": "Abyssinian",
                    "country": "Ethiopia",
                    "origin": "Natural/Standard",
                    "coat": "Short",
                    "pattern": "Ticked"
                }
            ],
            "current_page": 1,
            "total": 98
        }
        """.data(using: .utf8)!
        
        mockSession.mockData = mockCatData
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://catfact.ninja/breeds")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        
        // When
        catFetcher.loadCats(perPage: 30, page: 1) { result in
            // Then
            switch result {
            case .success(let catResult):
                XCTAssertEqual(catResult.data.count, 1)
                XCTAssertEqual(catResult.data.first?.breed, "Abyssinian")
                XCTAssertEqual(catResult.total, 98)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLoadCatsNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "Handle network error")
        mockSession.mockError = NSError(domain: "TestError", code: -1, userInfo: nil)
        
        // When
        catFetcher.loadCats(perPage: 30, page: 1) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                if case .networkError = error {
                    // Expected network error
                } else {
                    XCTFail("Expected network error but got \(error)")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLoadCatsInvalidData() {
        // Given
        let expectation = XCTestExpectation(description: "Handle invalid data")
        mockSession.mockData = "invalid json".data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://catfact.ninja/breeds")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        
        // When
        catFetcher.loadCats(perPage: 30, page: 1) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                if case .decodingError = error {
                    // Expected decoding error
                } else {
                    XCTFail("Expected decoding error but got \(error)")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
