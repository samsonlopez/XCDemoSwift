//
//  UserListViewModelTests.swift
//  XCDemoSwiftTests
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import XCTest
import CoreData

@testable import XCDemoSwift

class UserListViewModelTests: XCTestCase {

    var viewModelUnderTest: UserListViewModel!
    
    var dataService: DataService!
    var managedObjectContext: NSManagedObjectContext!
    
    override func setUp() {
        managedObjectContext = TestDataSetup.setUpInMemoryManagedObjectContext()
        viewModelUnderTest = UserListViewModel(dataService: DataService(), managedObjectContext: managedObjectContext)
        TestDataSetup.populateTestData(managedObjectContext: managedObjectContext)
    }

    override func tearDown() {
        managedObjectContext = nil
        viewModelUnderTest = nil
    }

    func testListViewModelInit_IsCreated() {
        XCTAssertNotNil(viewModelUnderTest, "UserListViewModel init failed")
    }
    
    func testFetchResultController_IsCreated() {
        let fetchResultController = viewModelUnderTest.createFetchResultsController(managedObjectContext: managedObjectContext)
        XCTAssertNotNil(fetchResultController, "FetchResultController create failed")
    }

    func testFetchResultController_ExecuteInitialFetchSuccessfull() {
        //viewModelUnderTest?._fetchedResultsController = MockFetchResultController()
        _ = viewModelUnderTest?.createFetchResultsController(managedObjectContext: managedObjectContext)
        let isSuccessfull = viewModelUnderTest.executeInitialFetch(fetchResultController: viewModelUnderTest!.fetchedResultsController)
        XCTAssertTrue(isSuccessfull, "FetchResultController executeInitialFetch failed")
    }

    func testFetchResultController_ExecuteInitialFetchFailed() {
        let isSuccessfull = viewModelUnderTest.executeInitialFetch(fetchResultController: MockFetchResultController())
        XCTAssertFalse(isSuccessfull, "FetchResultController executeInitialFetch not failed")
    }

    func testGetNumberOfRows_IsCorrectNumberOfRows() {
        let testDataNumberOfRows = TestDataSetup.testUsersData.count
        let numberOfRows = viewModelUnderTest.getNumberOfRows()
        XCTAssertEqual(testDataNumberOfRows, numberOfRows, "Incorrect number of rows returned")
    }
    
    func testGetCellViewModel_IsCorrectViewModel() {
        let cellViewModel = viewModelUnderTest.getCellViewModel(at: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(cellViewModel, "CellViewModel not returned")
        // Check with last record value of test data, due to sorting with userid in reverse order with latest on top.
        XCTAssertEqual(cellViewModel.name, TestDataSetup.testUsersData[1].name, "Name value for cell incorrect")
        // TODO: Check for all the other attributes.
    }

    func testGetUserViewData_IsCorrectData() {
        let userViewData = viewModelUnderTest.getUserViewData(at: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(userViewData, "UserViewData not returned")
        // Check with last record value of test data, due to sorting with userid in reverse order with latest on top.
        XCTAssertEqual(userViewData.name, TestDataSetup.testUsersData[1].name, "Name value for userViewData incorrect")
        // TODO: Check for the other attributes dob, gender, cob
    }
    
    func testGetNewUserID_ReturnsNonZeroValue() {
        guard let newUserID = try? viewModelUnderTest?.getNewUserID(context: managedObjectContext) else {
            XCTFail("Error thrown on getNewUserID")
            return
        }
        XCTAssertNotEqual(newUserID, 0, "Invalid new UserID returned")
        // TODO: More detailed check with sample data for valid new userID
    }

    func testGetNewUserID_ThrowsError() {
        let mocManagedObjectContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        XCTAssertThrowsError(try viewModelUnderTest.getNewUserID(context: mocManagedObjectContext), "Did not throw error")
    }

    func testAddNewUser_IsAddedToModel() {
        let userViewData = UserViewData(name: "Jack", dob: Date(), gender: "M", cob: "AU")
        _ = viewModelUnderTest.addNewUser(userViewData: userViewData, context: managedObjectContext)

        let addedUserViewData = viewModelUnderTest.getCellViewModel(at: IndexPath(row: 0, section: 0)) // Top most index is newest.
        XCTAssertEqual(userViewData.name, addedUserViewData.name, "Name value for userViewData incorrect")
        // TODO: Check for the other attributes dob, gender, cob
    }

    func testAddNewUser_FailsOnFetch() {
        let userViewData = UserViewData(name: "Jack", dob: Date(), gender: "M", cob: "AU")
        viewModelUnderTest.managedObjectContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let isSuccessfull = viewModelUnderTest!.addNewUser(userViewData: userViewData, context: managedObjectContext)
        XCTAssertFalse(isSuccessfull, "Insert did not fail as expected")
    }

    func testAddNewUser_FailsOnSave() {
        let userViewData = UserViewData(name: "Jack", dob: Date(), gender: "M", cob: "AU")
        let mockContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let isSuccessfull = viewModelUnderTest!.addNewUser(userViewData: userViewData, context: mockContext)
        XCTAssertFalse(isSuccessfull, "Insert did not fail as expected")
    }

    func testUpdateUser_IsUpdatedInModel() {
        let userViewData = UserViewData(name: "Jill", dob: Date(), gender: "F", cob: "UK")
        _ = viewModelUnderTest.updateUser(userViewData: userViewData, indexPath:IndexPath(row: 1, section: 0), context: managedObjectContext)
        
        let updatedUserViewData = viewModelUnderTest?.getCellViewModel(at: IndexPath(row: 1, section: 0)) // Top most index is newest.
        XCTAssertEqual(userViewData.name, updatedUserViewData!.name, "Name value for userViewData incorrect")
        // TODO: Check for the other attributes dob, gender, cob
    }

    func testUpdateUser_Fails() {
        let userViewData = UserViewData(name: "Jill", dob: Date(), gender: "F", cob: "UK")
        let mockContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let isSuccessfull = viewModelUnderTest.updateUser(userViewData: userViewData, indexPath:IndexPath(row: 1, section: 0), context: mockContext)
        XCTAssertFalse(isSuccessfull, "Update did not fail as expected")
    }

    func testDeleteUser_IsDeletedInModel() {
        let testDataNumberOfRows = TestDataSetup.testUsersData.count

        _ = viewModelUnderTest.deleteUser(indexPath: IndexPath(row: 1, section: 0), context: managedObjectContext) // Delete 2nd in list.

        let numberOfRows = viewModelUnderTest.getNumberOfRows()
        XCTAssertEqual(testDataNumberOfRows, numberOfRows+1, "Delete failed, user count not reduced")
        // TODO: Detailed check whether the correct user is deleted.
    }

    func testDeleteUser_Fails() {
        let mockContext = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let isSuccessfull = viewModelUnderTest.deleteUser(indexPath: IndexPath(row: 1, section: 0), context: mockContext) // Delete 2nd in list.
        XCTAssertFalse(isSuccessfull, "Delete did not fail as expected")
    }

}

// Mock FetchResultController used for unit testing UserListViewModel.
class MockFetchResultController: NSFetchedResultsController<User> {
    
    override func performFetch() throws {
        throw MockError.fetchError
    }
}

// Mock ManagedObjectContext to test error conditions
class MockManagedObjectContext: NSManagedObjectContext {
    override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
        throw MockError.fetchError
    }
}

// Errors thrown in mock classes/methods used for testing error conditions
enum MockError: String, Error {
    case fetchError = "Fetch error"
    case saveError = "Save error"
}
