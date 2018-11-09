//
//  SubmitViewModelTests.swift
//  XCDemoSwiftTests
//
//  Created by Samson Lopez on 01/11/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import XCTest
import CoreData

@testable import XCDemoSwift

class SubmitViewModelTests: XCTestCase {

    var viewModelUnderTest: SubmitViewModel!
    
    var managedObjectContext: NSManagedObjectContext!
    var mockDataService: MockDataService!
    
    override func setUp() {
        managedObjectContext = TestDataSetup.setUpInMemoryManagedObjectContext()
        mockDataService = MockDataService()
        viewModelUnderTest = SubmitViewModel(dataService: mockDataService, managedObjectContext: managedObjectContext)
        TestDataSetup.populateTestData(managedObjectContext: managedObjectContext)
    }

    override func tearDown() {
    }
    
    func testInit_InitializedCorrectly() {
        viewModelUnderTest = SubmitViewModel(dataService: DataService(), managedObjectContext: TestDataSetup.setUpInMemoryManagedObjectContext())
        XCTAssertNotNil(viewModelUnderTest, "SubmitViewModel not initialized, return nil")
    }

    func testGetUserData_ReturnsUserData() {
        let userData = viewModelUnderTest.getUserData()
        XCTAssertNotNil(userData, "User data not returned")
        XCTAssertEqual(userData!.count, TestDataSetup.testUsersData.count, "User data row count does not match")
    }

    func testGetUserData_Failed() {
        let mockManagedObjectContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewModelUnderTest.managedObjectContext = mockManagedObjectContext
        let userData = viewModelUnderTest.getUserData()
        XCTAssertNil(userData, "User data is not nil as expected")
    }

    func testSubmit_UsingCompletionHandler_SubmitSuccessfull() {
        mockDataService.isSimulateError = false
        var isSuccessfull = false
        viewModelUnderTest.submit(complete: { (status, error) in
            if(status == true) {
                isSuccessfull = true
            } else {
                isSuccessfull = false
            }
        })
        XCTAssertTrue(isSuccessfull, "Submit not successfull")
    }

    func testSubmit_SubmitFailed() {
        mockDataService.isSimulateError = true
        var isSuccessfull = false
        viewModelUnderTest.submit(complete: { (status, error) in
            if(status == true) {
                isSuccessfull = true
            } else {
                isSuccessfull = false
            }
        })
        XCTAssertFalse(isSuccessfull, "Submit not failed")
    }
    
}

class MockDataService: DataService {
    var isSimulateError = false
    
    override func submit(data: Data, uploadSession: URLSession, complete: @escaping (Bool, DataServiceError?) -> ()) {
        if(isSimulateError) {
            complete(false, DataServiceError.uploadFailed)
        } else {
            complete(true, nil)
        }
    }
}
