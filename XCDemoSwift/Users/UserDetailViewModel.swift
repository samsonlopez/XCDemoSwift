//
//  UserDetailViewModel.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation

// ViewModel definition for UserDetailViewController (MVVM Architecture)

class UserDetailViewModel {
    
    // CountryCodes used for validation
    var countryCodes = [String]();

    // Properties with observers (didSet) to validate input controls and call closures defined/assigned in the viewController
    // for displaying validation status.
    
    var name: String? {
        didSet {
            let isValid = validateName(name)
            validateNameClosure?(isValid)
        }
    }

    var dob: Date? {
        didSet {
            let isValid = validateDob(dob)
            validateDobClosure?(isValid)
        }
    }
    
    var gender: String? {
        didSet {
            if let gender = gender {
                if gender=="Male" {
                    self.gender = "M"
                } else if gender=="Female" {
                    self.gender = "F"
                }
            }
            let isValid = validateGender(gender)
            validateGenderClosure?(isValid)
        }
    }

    var cob: String? {
        didSet {
            let isValid = validateCob(cob)
            validateCobClosure?(isValid)
        }
    }
    
    // Required default initializer as other convenience initializer is defined with optionals
    init() {
    }
    
    init(name: String?, dob: Date?, gender: String?, cob: String?) {
        self.name = name
        self.dob = dob
        self.gender = gender
        self.cob = cob
    }
    
    var validateNameClosure: ((Bool)->())?
    var validateDobClosure: ((Bool)->())?
    var validateGenderClosure: ((Bool)->())?
    var validateCobClosure: ((Bool)->())?
    var loadUserClosure: (()->())?

    func validateName(_ name: String?) -> Bool {
        var isValid: Bool
        if let name = name {
            if(name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0) {
                isValid = false;
            } else {
                isValid = true;
            }
        } else {
            isValid = false;
        }
        
        return isValid
    }

    func validateDob(_ dob: Date?) -> Bool {
        var isValid: Bool
        if let dob = dob {
            if(dob > Date()) {
                isValid = false;
            } else {
                isValid = true;
            }
        } else {
            isValid = false;
        }
        return isValid
    }

    func validateGender(_ gender: String?) -> Bool {
        var isValid: Bool
        if let gender = gender {
            let genderStr = gender.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if genderStr=="M" || genderStr=="F" {
                isValid = true
            } else {
                isValid = false
            }
        } else {
            isValid = false;
        }
        return isValid
    }

    func validateCob(_ cob: String?) -> Bool {
        var isValid: Bool
        if (cob==nil) {
            isValid = false
        } else {
            isValid = true
        }
        return isValid
    }

    func validateDataControls() -> Bool {
        var isValid = true
        
        if(!validateName(name)) {
            isValid = false
            validateNameClosure?(isValid)
        }

        if(!validateGender(gender)) {
            isValid = false
            validateGenderClosure?(isValid)
        }

        if(!validateDob(dob)) {
            isValid = false
            validateDobClosure?(isValid)
        }

        if(!validateCob(cob)) {
            isValid = false
            validateCobClosure?(isValid)
        }

        return isValid;
    }
    
    func load(userViewData: UserViewData) {
        self.name = userViewData.name
        self.dob = userViewData.dob
        self.gender = userViewData.gender
        self.cob = userViewData.cob
        
        loadUserClosure?()
    }
    
    func getUserViewData() -> UserViewData? {
        var userViewData: UserViewData? = nil
        if let name = name, let dob = dob, let cob = cob, let gender = gender {
            userViewData = UserViewData(name:name, dob:dob, gender:gender, cob:cob)
        }
        return userViewData
    }
    
    func setGender(index: Int) {
        if index==0 {
            self.gender = "M"
        } else {
            self.gender = "F"
        }
    }
    
}
