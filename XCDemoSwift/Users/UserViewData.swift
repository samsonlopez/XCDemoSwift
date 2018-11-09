//
//  UserViewData.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation

// UserViewData is used for passing data between ViewController, ViewModel and Model.
// The structure is independent of viewModel properties for fields.

// NOTE: This is based on ViewData design pattern in addition to MVVM for passing data between view and model.

struct UserViewData {
    var name: String
    var dob: Date
    var gender: String
    var cob: String
}
