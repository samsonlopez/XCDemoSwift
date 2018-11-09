//
//  DataServiceTests.swift
//  XCDemoSwiftTests
//
//  Created by Samson Lopez on 31/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import XCTest
@testable import XCDemoSwift

class DataServiceTests: XCTestCase {
    
    var dataServiceUnderTest: DataService!
    
    // Data used for tests.
    let userData = [UserData(name: "John", dob: Date(), gender: "M", cob: "UK"),
                    UserData(name: "Jane", dob: Date(), gender: "F", cob: "US")]


    override func setUp() {
        dataServiceUnderTest = DataService()
    }

    override func tearDown() {
        dataServiceUnderTest = nil
    }

    func testGetURLRequestForPOST_IsCreated() {
        let urlRequest = dataServiceUnderTest.getURLRequestForPOST()
        XCTAssertNotNil(urlRequest, "URLRequest is nil")
        XCTAssertEqual(urlRequest.httpMethod, "POST", "Wrong http method")
    }

    func testGetURLSession_IsCreated() {
        let urlSession = dataServiceUnderTest.getURLSession()
        XCTAssertNotNil(urlSession, "URLSession is nil")
    }

    // The two submit tests below demonstrates use of XCTestExpectation to wait for REST/asyncronous calls.
    
    // Mock objects (defined in MockDataServiceClasses) for Session and Task are used for the dependencies.
    
    func testSubmitWithCompletionHandler_IsSubmitSuccessfull() {
        
        // Create a mock session object which DOES NOT return an Error.
        let urlSession = MockURLSession(data: nil, response:nil, error: nil)
        XCTAssertNotNil(urlSession, "URLSession is nil")
        
        
        let jsonData = try? JSONEncoder().encode(userData)

        let expectation = XCTestExpectation(description: "Submit call returns result")
        var isSuccessfull = false;
        dataServiceUnderTest.submit(data: jsonData!, uploadSession: urlSession) { (success, error) in
            if success {
                isSuccessfull = true
            }
            expectation.fulfill() // Expectation is fullfilled even if submission fails.
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(isSuccessfull, "Submission not successfull")
    }
    
    enum SubmissionFailedError: Error {
        case submissionFailed
    }
    
    func testSubmitWithCompletionHandler_IsSubmitFailed() {
        
        // Create a mock session object which DOES return an Error.
        let urlSession = MockURLSession(data: nil, response:nil, error: SubmissionFailedError.submissionFailed)
        XCTAssertNotNil(urlSession, "URLSession is nil")
        
        let jsonData = try? JSONEncoder().encode(userData)

        let expectation = XCTestExpectation(description: "Submit call returns result")
        var isSuccessfull = false;
        dataServiceUnderTest.submit(data: jsonData!, uploadSession: urlSession) { (success, error) in
            if success {
                isSuccessfull = true
            }
            expectation.fulfill() // Expectation is fullfilled even if submission fails.
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(!isSuccessfull, "Submission did not fail")
    }

}
