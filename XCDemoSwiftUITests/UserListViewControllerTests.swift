//
//  UserListViewControllerTests.swift
//  XCDemoSwiftUITests
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import XCTest

@testable import XCDemoSwift

class UserListViewControllerTests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    // Test standar UI flow for user addition
    func testAddUser() {
        
        let app = XCUIApplication()
        
        let cellCountBeforeAdd = app.tables.cells.count

        addUser(app: app)
        
        let cellCountAfterAdd = app.tables.cells.count
        XCTAssertEqual(cellCountAfterAdd, cellCountBeforeAdd+1, "Add user failed")
    }
    
    func addUser(app: XCUIApplication) {
        app.navigationBars["Users"].buttons["Add"].tap()
        
        let tablesQuery = app.tables
        
        tablesQuery.cells["Name"].children(matching: .textField).element.tap()
        let nameTextField = tablesQuery.cells["Name"].children(matching: .textField).element
        nameTextField.typeText("John")
        
        tablesQuery.cells["D.O.B"].children(matching: .textField).element.tap()
        let dobTextField = tablesQuery.cells["D.O.B"].children(matching: .textField).element
        dobTextField.typeText("10/10/1990")
        
        app.tables.cells.containing(.staticText, identifier:"Gender").children(matching: .textField).element.tap()
        let genderTextField = tablesQuery.cells["Gender"].children(matching: .textField).element
        genderTextField.typeText("Male")
        
        tablesQuery.cells.containing(.staticText, identifier:"Country of Birth").children(matching: .textField).element.tap()
        app.tables.staticTexts["Greenland"].tap()
        
        app.navigationBars["Add User"].buttons["Save"].tap()
    }

    // Test standard UI flow for user edit
    func testEditUser() {
        
        let app = XCUIApplication()
        
        addUser(app: app)
        
        // Now edit user.
        
        app.tables.cells.element(boundBy: 0).children(matching: .other).element(boundBy: 0).tap()
        
        let tablesQuery = app.tables
        
        tablesQuery.cells["Name"].children(matching: .textField).element.tap()
        let nameTextField = tablesQuery.cells["Name"].children(matching: .textField).element
        
        let oldNameTextFieldValue = nameTextField.value as! String

        let characterCount: Int = oldNameTextFieldValue.count
        for _ in 0..<characterCount {
            nameTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        
        nameTextField.typeText("Jack")
        
        app.navigationBars["Edit User"].buttons["Save"].tap()
        
        XCUIApplication().tables.cells.element(boundBy: 0).children(matching: .other).element(boundBy: 0).tap()

        tablesQuery.cells["Name"].children(matching: .textField).element.tap()
        let nameEditTextField = tablesQuery.cells["Name"].children(matching: .textField).element
        let newNameTextFieldValue = nameEditTextField.value as! String

        XCTAssertNotEqual(oldNameTextFieldValue, newNameTextFieldValue, "Edit user failed")
    }
    
    // Test standard UI flow for user delete
    func testDeleteUser() {
        
        let app = XCUIApplication()
        
        addUser(app: app)
        
        // Now delete user.

        let cellCountBeforeDelete = app.tables.cells.count

        app.navigationBars["Users"].buttons["Edit"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.element(boundBy: 0).buttons.element(boundBy: 0).tap()
        //tablesQuery/*@START_MENU_TOKEN@*/.cells["Jill, 10/10/1990 Male Argentina"].buttons["Delete Jill, 10/10/1990 Male Argentina"]/*[[".cells[\"Jill, 10\/10\/1990 Male Argentina\"].buttons[\"Delete Jill, 10\/10\/1990 Male Argentina\"]",".buttons[\"Delete Jill, 10\/10\/1990 Male Argentina\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.buttons["Delete"].tap()

        app.navigationBars["Users"].buttons["Done"].tap()

        let cellCountAfterDelete = app.tables.cells.count
        XCTAssertEqual(cellCountBeforeDelete, cellCountAfterDelete+1, "Delete user failed")

    }
    
    // Test standard UI flow for data submit
    func testSubmit() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Submit"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.buttons["Submit"].tap()

        sleep(2) // Wait for 2 seconds which is the timeout for submit.
        //let successLabelText = "Submission Successfull!"
        
        // We are just testing if the submit UI flow is working, so the test is failure label is shown.
        // As dataservice url is not active and functioning, we just test for failed condition which covers the UI flow.
        let failedLabelText = "Submission Failed!"
        let isFailed = app.staticTexts[failedLabelText].exists
        XCTAssertTrue(isFailed, "Submit did not complete")
        
    }
    
}
