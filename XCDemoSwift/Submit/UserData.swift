//
//  UserData.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 30/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation

// UserData is used as viewModel object for User in submitViewModel
// Serializable - used for creating JSON and submitting to REST service.
struct UserData: Codable {
    var name: String
    var dob: Date
    var gender: String
    var cob: String
}
