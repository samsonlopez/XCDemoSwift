//
//  CommonTests.swift
//  XCDemoSwiftTests
//
//  Created by Samson Lopez on 01/11/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation
import XCTest

@testable import XCDemoSwift

class CommonTests: XCTestCase {

    func testIndexFromGender_ReturnsWithCorrectIndex() {
        let index0 = indexFromGender("M")
        XCTAssertEqual(index0, 0, "Index value for M should be 0")
        let index1 = indexFromGender("F")
        XCTAssertEqual(index1, 1, "Index value for F should be 1")
    }

    func testGenderFromIndex_ReturnsWithCorrectGender() {
        let gender0 = genderFromIndex(0)
        XCTAssertEqual(gender0, "Male", "Gender value for 0 should be Male")
        let gender1 = genderFromIndex(1)
        XCTAssertEqual(gender1, "Female", "Gender value for 1 should be Female")
    }

    func testGenderFromShortString_ReturnsWithCorrectGender() {
        let gender0 = genderFromShortString("M")
        XCTAssertEqual(gender0, "Male", "Gender value for 0 should be Male")
        let gender1 = genderFromShortString("F")
        XCTAssertEqual(gender1, "Female", "Gender value for 1 should be Female")
    }
}
