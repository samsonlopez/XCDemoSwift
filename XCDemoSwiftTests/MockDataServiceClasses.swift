//
//  MockTestClasses.swift
//  XCDemoSwiftTests
//
//  Created by Samson Lopez on 31/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation
import XCTest

@testable import XCDemoSwift

// Mock classes used for testing DataService

class MockURLSessionUploadTask: URLSessionUploadTask {
    
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    var completionHandler: CompletionHandler?
    var taskResponse: (Data?, URLResponse?, Error?)?
    
    override func resume() {
        // Call completion handler (To test Method 1: Completion handler based submit)
        DispatchQueue.main.async {
            self.completionHandler?(self.taskResponse?.0, self.taskResponse?.1, self.taskResponse?.2)
        }
    }
}

class MockURLSession: URLSession {
    
    var url: URL?
    var request: URLRequest?
    private let mocUploadDataTask: MockURLSessionUploadTask
    
    init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        mocUploadDataTask = MockURLSessionUploadTask()
        mocUploadDataTask.taskResponse = (data, response, error)
    }
    
    init(error: Error?) {
        mocUploadDataTask = MockURLSessionUploadTask()
        mocUploadDataTask.taskResponse = (nil, nil, error)
    }
    
    override func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        self.request = request
        self.mocUploadDataTask.completionHandler = completionHandler
        
        return self.mocUploadDataTask
    }
    
    override func uploadTask(with request: URLRequest, from bodyData: Data?) -> URLSessionUploadTask {
        self.request = request
        
        return self.mocUploadDataTask
    }
}
