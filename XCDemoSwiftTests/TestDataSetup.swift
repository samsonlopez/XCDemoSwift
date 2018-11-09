//
//  TestDataSetup.swift
//  XCDemoSwiftTests
//
//  Created by Samson Lopez on 01/11/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation
import CoreData

@testable import XCDemoSwift

class TestDataSetup {
    
    // Test data - used for unit tests in multiple test classes.
    // Note that rows will be listed in CoreData in reverse order due to sorting by userid.
    static let testUsersData = [UserData(name: "John", dob: Date(), gender: "M", cob: "UK"),
                                UserData(name: "Jane", dob: Date(), gender: "F", cob: "US")]

    // Populate test data is used in multiple test classes.
    static func populateTestData(managedObjectContext: NSManagedObjectContext) {
        
        var newUserID = 1
        for data in testUsersData {
            let newUser = User(context: managedObjectContext)
            
            newUser.userid = NSNumber(value: newUserID)
            newUser.name = data.name
            newUser.dob = data.dob
            newUser.gender = data.gender
            newUser.cob = data.cob
            
            // NOTE: Localization not in scope (Dates etc) for thie demo and not covered.
            newUser.timeStamp = Date()
            
            newUserID += 1
        }
        
        // Save test data to the context.
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // Setup in-memory managedObjectContext, test data is used unit tests in multiple test classes.
    static func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        
        // Get object model from app bundle
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Error creating in-memory managedObjectContext")
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
}
