//
//  UserListViewModel.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import Foundation
import CoreData

// ViewModel definition for UserListViewController (MVVM Architecture)

class UserListViewModel: NSObject, NSFetchedResultsControllerDelegate {
    
    // Constants
    let fetchBatchSize = 20
    
    // Dependencies
    let dataService: DataService
    var managedObjectContext: NSManagedObjectContext
    // Note: FetchResultsController is also a dependency, and can be injected via create method.
    
    typealias ViewModelUpdateClosure = (()->())?
    var reloadListViewClosure: ViewModelUpdateClosure
    
    var insertListItemClosure: ((IndexPath?)->())?
    var updateListItemClosure: ((IndexPath?)->())?
    var deleteListItemClosure: ((IndexPath?)->())?

    init(dataService: DataService = DataService(), managedObjectContext: NSManagedObjectContext) {
        self.dataService = dataService
        self.managedObjectContext = managedObjectContext
    }
    
    func getNumberOfRows() -> Int {
        let sectionInfo = fetchedResultsController.sections![0]
        return sectionInfo.numberOfObjects
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> UserListCellViewModel {
        let user = fetchedResultsController.object(at: indexPath)

        var userListCellViewModel: UserListCellViewModel! // We know that data from model is complete for all attributes, so safely force unwrap.
        if let name = user.name, let dob = user.dob, let gender = user.gender, let cob = user.cob {
            userListCellViewModel = UserListCellViewModel(name:name, dob: dob, gender: gender, cob: cob)
        }
        
        return userListCellViewModel
    }
    
    func getUserViewData(at indexPath: IndexPath) -> UserViewData {
        let user = fetchedResultsController.object(at: indexPath)
        
        var userViewData: UserViewData!  // We know that data from model is complete for all attributes, so safely force unwrap.
        if let name = user.name, let dob = user.dob, let gender = user.gender, let cob = user.cob {
            userViewData = UserViewData(name:name, dob: dob, gender: gender, cob: cob)
        }
        
        return userViewData
    }
    
    // Adds a new user to the list and model.
    func addNewUser(userViewData: UserViewData, context: NSManagedObjectContext) -> Bool {
        let fetchContext = managedObjectContext // To differentiate between fetch and save context used for unit testing.

        let newUser = User(context: fetchContext)
        
        // Configure the new user object.
        var newUserID:Int?
        do {
            try newUserID = getNewUserID(context: fetchContext)
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
        
        if let newUserID = newUserID {
            newUser.userid = NSNumber(value: newUserID)
            newUser.name = userViewData.name
            newUser.dob = userViewData.dob
            newUser.gender = userViewData.gender
            newUser.cob = userViewData.cob
            
            // NOTE: Localization not in scope (Dates etc) for this demo.
            newUser.timeStamp = Date()
            
            // Save context
            if !saveContext(context) {
                return false
            }
        }
        
        return true
    }
    
    func getNewUserID(context fetchContext: NSManagedObjectContext) throws -> Int {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.fetchBatchSize = 1
        let sortDescriptor = NSSortDescriptor(key: "userid", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var maxUser: User?
        do {
            try maxUser = fetchContext.fetch(fetchRequest).first
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            throw error
        }

        var newUserid = 1
        if let userid = maxUser?.userid {
            newUserid = userid.intValue + 1
        }
        print("New userid=\(newUserid)")

        return newUserid
    }
    
    // Note: The demo assumes an ordered list without any concurrent access to keep it simple.
    // Order index of the list is used for delete/update.

    // Updates user details in the list and model.
    func updateUser(userViewData: UserViewData, indexPath: IndexPath, context: NSManagedObjectContext) -> Bool  {
        
        let user = fetchedResultsController.object(at: indexPath)
        
        user.name = userViewData.name
        user.dob = userViewData.dob
        user.gender = userViewData.gender
        user.cob = userViewData.cob
        user.timeStamp = Date()
        
        return saveContext(context)
    }

    // Deletes user from the list / model.
    func deleteUser(indexPath: IndexPath, context: NSManagedObjectContext) -> Bool {
        let fetchContext = managedObjectContext // To differentiate between fetch and save context used for unit testing.

        fetchContext.delete(fetchedResultsController.object(at: indexPath))
        return saveContext(context)
    }
    
    func saveContext(_ context: NSManagedObjectContext) -> Bool {
        do {
            try context.save()
        } catch {
            // TODO: Replace this to handle the error appropriately.
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
        
        return true
    }
    
    // MARK: - Fetched results controller
    
    // The binding between the ViewModel and Model is via the FetchResultsController.
    
    var fetchedResultsController: NSFetchedResultsController<User> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        _fetchedResultsController = createFetchResultsController(managedObjectContext: managedObjectContext)
        _ = executeInitialFetch(fetchResultController: _fetchedResultsController!)
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<User>? = nil
    
    func createFetchResultsController(managedObjectContext: NSManagedObjectContext) -> NSFetchedResultsController<User> {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.fetchBatchSize = fetchBatchSize
        
        let sortDescriptor = NSSortDescriptor(key: "userid", ascending: false) // Newest on top of the list.
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let theFetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "Master")
        theFetchResultController.delegate = self
        
        return theFetchResultController
    }
    
    func executeInitialFetch(fetchResultController: NSFetchedResultsController<User>) -> Bool {
        do {
            try fetchResultController.performFetch()
        } catch {
            // TODO: Replace this to handle the error appropriately.
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
        
        return true
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.insertListItemClosure?(newIndexPath!)
        case .delete:
            self.deleteListItemClosure?(indexPath!)
        case .update:
            self.updateListItemClosure?(indexPath!)
        case .move:
           // Not implemented, out of scope for this demo
            break
        }
    }
    
}

// ViewModel for the user table cell, does not contain any logic.
struct UserListCellViewModel {
    let name: String
    let dob: Date
    let gender: String
    let cob: String
}
