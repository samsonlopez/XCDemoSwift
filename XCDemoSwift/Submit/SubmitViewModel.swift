//
//  SubmitViewModel.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation
import CoreData

class SubmitViewModel {
    
    // Data service to download/upload data from server.
    let dataService: DataService?
    
    // Time out value for data download/upload requests.
    let timeOut = 5

    // Core data managed object context to fetch locally store data.
    var managedObjectContext: NSManagedObjectContext?
    
    init(dataService: DataService, managedObjectContext: NSManagedObjectContext) {
        self.dataService = dataService
        self.managedObjectContext = managedObjectContext
    }
    
    // Retrieves locally stored user data from CoreData context.
    func getUserData() -> [UserData]? {
        var users: [UserData]?
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "userid", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var fetchResult:[User]?
        do {
            try fetchResult = self.managedObjectContext?.fetch(fetchRequest)
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        if(fetchResult != nil) {
            print("fetchResult count=\(fetchResult!.count)")
            
            users = [UserData]()
            
            for user: User in fetchResult! {
                if let name = user.name, let dob = user.dob, let gender = user.gender, let cob = user.cob {
                    users?.append(UserData(name: name, dob: dob, gender:gender, cob: cob))
                }
            }
        }
        
        return users
    }
    
    // Submits local data to server.
    func submit(complete: @escaping (_ success: Bool, _ error: DataServiceError?) -> ()) {
        let users = getUserData()
        
        let jsonData = try? JSONEncoder().encode(users)
        if let encodedObjectJsonString = String(data: jsonData!, encoding: .utf8) {
            print(encodedObjectJsonString)
        }

        let uploadSession = dataService?.getURLSession()
        
        if let jsonData = jsonData, let uploadSession = uploadSession {
            
            // DataServce.submit is invoked using completion handler method.
            dataService?.submit(data: jsonData, uploadSession: uploadSession) { (success, error) in
                complete(success, error)
            }
        }
    }

}
