//
//  UserDetailViewModelTests.swift
//  XCDemoSwiftTests
//
//  Created by Samson Lopez on 31/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import XCTest
@testable import XCDemoSwift

class UserDetailViewModelTests: XCTestCase {

    var viewModelUnderTest: UserDetailViewModel!

    override func setUp() {
        viewModelUnderTest = UserDetailViewModel()
    }

    override func tearDown() {
        viewModelUnderTest = nil
    }
    
    func testInit_IsCreatedCorrectly() {
        viewModelUnderTest = UserDetailViewModel(name: "John", dob: Date(), gender: "M", cob: "UK")
        XCTAssertEqual(viewModelUnderTest.name, "John", "Name not set correctly")
        // TODO: Assert for all other values.
    }
    
    // MARK: - Validation tests
    
    func testValidateName_IsValid() {
        let isValid = viewModelUnderTest.validateName("John")
        XCTAssertTrue(isValid, "Name validation failed")
    }

    func testValidateName_IsNotValid() {
        var isValid = viewModelUnderTest.validateName("")
        XCTAssertFalse(isValid, "Name validation for empty string did not fail")
        isValid = viewModelUnderTest.validateName(nil)
        XCTAssertFalse(isValid, "Name validation for nil did not fail")
    }
    
    func testValidateDob_IsValid() {
        let isValid = viewModelUnderTest.validateDob(Date())
        XCTAssertTrue(isValid, "Dob validation failed")
    }
    
    func testValidateDob_IsNotValid() {
        let isValid = viewModelUnderTest.validateDob(nil)
        XCTAssertFalse(isValid, "Dob validation for nil did not fail")
    }

    func testValidateGender_IsValid() {
        let isValid = viewModelUnderTest.validateGender("M")
        XCTAssertTrue(isValid, "Gender validation failed")
    }
    
    func testValidateGender_IsNotValid() {
        let isValid = viewModelUnderTest.validateGender(nil)
        XCTAssertFalse(isValid, "Gender validation for nil did not fail")
    }

    func testValidateCob_IsValid() {
        let isValid = viewModelUnderTest.validateCob("UK")
        XCTAssertTrue(isValid, "Cob validation failed")
    }
    
    func testValidateCob_IsNotValid() {
        let isValid = viewModelUnderTest.validateCob(nil)
        XCTAssertFalse(isValid, "Cob validation for nil did not fail")
    }

    func testValidateDataControls_AllControlsValid() {
        viewModelUnderTest.name = "John"
        viewModelUnderTest.dob = Date()
        viewModelUnderTest.gender = "M"
        viewModelUnderTest.cob = "UK"
        let isValid = viewModelUnderTest.validateDataControls()
        XCTAssertTrue(isValid, "All controls validation failed")
    }

    func testValidateDataControls_AllControlsInvalid() {
        viewModelUnderTest.name = "" // To cause validation failed.
        viewModelUnderTest.dob = Date()
        viewModelUnderTest.gender = "M"
        viewModelUnderTest.cob = "UK"
        var isValid = viewModelUnderTest.validateDataControls()
        XCTAssertFalse(isValid, "All controls validation not failed at name")
        viewModelUnderTest.name = "John"
        viewModelUnderTest.dob = nil  // To cause validation failed.
        viewModelUnderTest.gender = "M"
        viewModelUnderTest.cob = "UK"
        isValid = viewModelUnderTest.validateDataControls()
        XCTAssertFalse(isValid, "All controls validation not failed at dob")
        viewModelUnderTest.name = "John"
        viewModelUnderTest.dob = Date()
        viewModelUnderTest.gender = nil // To cause validation failed.
        viewModelUnderTest.cob = "UK"
        isValid = viewModelUnderTest.validateDataControls()
        XCTAssertFalse(isValid, "All controls validation not failed at gender")
        viewModelUnderTest.name = "John"
        viewModelUnderTest.dob = Date()
        viewModelUnderTest.gender = "M"
        viewModelUnderTest.cob = nil // To cause validation failed.
        isValid = viewModelUnderTest.validateDataControls()
        XCTAssertFalse(isValid, "All controls validation not failed at cob")
    }

    func testLoadUserViewData_AllControlsLoadedWithData() {
        let userViewData = UserViewData(name: "Jill", dob: Date(), gender: "F", cob: "UK")
        viewModelUnderTest.load(userViewData: userViewData)
        XCTAssertEqual(viewModelUnderTest.name, userViewData.name, "Name not loaded correctly")
        // TODO: Assert equal for all other data values.
    }

    func testGetUserViewData_ReturnsWithData() {
        viewModelUnderTest.name = "John"
        viewModelUnderTest.dob = Date()
        viewModelUnderTest.gender = "M"
        viewModelUnderTest.cob = "UK"
        let userViewData = viewModelUnderTest.getUserViewData()
        XCTAssertEqual(viewModelUnderTest.name, userViewData?.name, "Name not returned correctly")
        // TODO: Assert equal for all other data values.
    }
    
    // MARK: - Property setting & validation closure tests

    func testValidateNameClosure_ExecutesAndValidates() {
        var isClosureExecuted = false
        var isPropertyValid = false
        viewModelUnderTest.validateNameClosure = { (isValid: Bool) -> () in
            isClosureExecuted = true
            isPropertyValid = isValid
        }
        viewModelUnderTest.name = "John"
        XCTAssertTrue(isPropertyValid, "Validation failed for valid name")
        XCTAssertTrue(isClosureExecuted, "Closure not executed for name")

        isPropertyValid = false
        viewModelUnderTest.name = ""
        XCTAssertFalse(isPropertyValid, "Validation did not fail for invalid/blank name")
    }

    func testValidateDobClosure_ExecutesAndValidates() {
        var isClosureExecuted = false
        var isPropertyValid = false
        viewModelUnderTest.validateDobClosure = { (isValid: Bool) -> () in
            isClosureExecuted = true
            isPropertyValid = isValid
        }
        
        var dateComponents = DateComponents()
        dateComponents.setValue(1, for: .day); // +1 day
        
        let today = Date() // Current date
        let tomorrow = Calendar.current.date(byAdding: dateComponents, to: today)
        
        viewModelUnderTest.dob = today
        XCTAssertTrue(isPropertyValid, "Validation failed for valid dob")
        XCTAssertTrue(isClosureExecuted, "Closure not executed for dob")

        isPropertyValid = false
        viewModelUnderTest.dob = tomorrow
        XCTAssertFalse(isPropertyValid, "Validation did not fail for invalid dob")
    }

    func testValidateGenderClosure_ExecutesAndValidates() {
        var isClosureExecuted = false
        var isPropertyValid = false
        viewModelUnderTest.validateGenderClosure = { (isValid: Bool) -> () in
            isClosureExecuted = true
            isPropertyValid = isValid
        }
        viewModelUnderTest.gender = "Male"
        XCTAssertTrue(isPropertyValid, "Validation failed for valid gender = Male")
        XCTAssertTrue(isClosureExecuted, "Closure not executed for gender = Male")
        
        isPropertyValid = false
        viewModelUnderTest.gender = "Female"
        XCTAssertTrue(isPropertyValid, "Validation failed for valid gender = Female")
        
        isPropertyValid = false
        viewModelUnderTest.gender = ""
        XCTAssertFalse(isPropertyValid, "Validation did not fail for invalid gender")

    }

    func testValidateCobClosure_ExecutesAndValidates() {
        var isClosureExecuted = false
        var isPropertyValid = false
        viewModelUnderTest.validateCobClosure = { (isValid: Bool) -> () in
            isClosureExecuted = true
            isPropertyValid = isValid
        }
        viewModelUnderTest.cob = "UK"
        XCTAssertTrue(isClosureExecuted, "Closure not executed for cob")

        isPropertyValid = false
        viewModelUnderTest.cob = nil
        XCTAssertFalse(isPropertyValid, "Validation did not fail for invalid cob")
    }

    // Tests for all closure properties used for property bindings.
    // The closures should be executed to pass.
    
    func testLoadUserViewData_LoadClosureExecutes() {
        var isClosureExecuted = false
        viewModelUnderTest.loadUserClosure = {
            isClosureExecuted = true
        }
        let userViewData = UserViewData(name: "Jill", dob: Date(), gender: "F", cob: "UK")
        viewModelUnderTest.load(userViewData: userViewData)
        XCTAssertTrue(isClosureExecuted, "Closure not executed")
    }

    // MARK: - Gender helper method for input/validation tests
    
    func testSetGenderWithIndex_GenderValueIsSet() {
        viewModelUnderTest.setGender(index: 0)
        XCTAssertEqual(viewModelUnderTest.gender, "M", "Gender value for 0 should be M")
        viewModelUnderTest.setGender(index: 1)
        XCTAssertEqual(viewModelUnderTest.gender, "F", "Gender value for 1 should be F")
    }

}
