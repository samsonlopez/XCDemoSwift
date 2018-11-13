//
//  Common.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation

// Locale out of scope for this demo.
func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = DateFormatter.Style.short
    dateFormatter.dateFormat = "dd'/'MM'/'yyyy"
    let formattedDate = dateFormatter.string(from: date)
    
    return formattedDate
}

// Used in gender UI display
func indexFromGender(_ gender: String) -> Int {
    var index = 0
    
    if gender == "M" {
        index = 0
    } else if gender == "F" {
        index = 1
    }
    
    return index;
}

// Used in gender UI display
func genderFromIndex(_ index: Int) -> String {
    var returnStr = ""
    
    if index==0 {
        returnStr = "Male"
    } else {
        returnStr = "Female"
    }
    
    return returnStr
}

// Used in gender UI display
func genderFromShortString(_ gender: String) -> String {
    var retString = "M";
    
    if gender == "M" {
        retString = "Male";
    } else if gender == "F" {
        retString = "Female";
    }
    
    return retString;
}

// Used in cob UI display, lookup and validation
class Countries {
    
    // Arrays and look up dictonary for countries.
    static var countryCodes = [String]();
    static var countryNames = [String]();
    static var countriesDictonary = [String: String]()
    
    // Retrieve contries list from NSLocale and load the countries data structure used in countries lookup.
    static func loadCountries() {
        let locale = NSLocale.current
        countryCodes = NSLocale.isoCountryCodes
        
        for countryCode in countryCodes {
            if let countryName = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode) {
                countryNames.append(countryName)
                countriesDictonary[countryCode] = countryName
            }
        }
    }
    
}
