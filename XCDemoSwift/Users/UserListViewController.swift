//
//  UserListViewController.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import UIKit
import CoreData

class UserListViewController: UITableViewController {

    // ViewModel property for UserListViewController (MVVM Architecture)
    lazy var viewModel: UserListViewModel = {
        return UserListViewModel(dataService: DataService(), managedObjectContext: self.managedObjectContext!)
    }()
    
    // Child view controllers
    var userDetailViewController: UserDetailViewController? = nil
    
    // Core data context
    weak var managedObjectContext: NSManagedObjectContext? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Clousures Binding UI response actions to the ViewModel events for NSFetchedResultsController.
        
        // NOTE: There are other ways to do this using KVO, Notifications or external binding/reactive frameworks
        // but a simple swift closure + property observer binding method is used here.
        
        self.viewModel.insertListItemClosure = { [weak self] (newIndexPath) -> () in
            self?.tableView.insertRows(at: [newIndexPath!], with: .fade)
        }

        self.viewModel.deleteListItemClosure = { [weak self] (indexPath) -> () in
            self?.tableView.deleteRows(at: [indexPath!], with: .fade)
        }

        self.viewModel.updateListItemClosure = { [weak self] (indexPath) -> () in
            let cellViewModel = self?.viewModel.getCellViewModel(at: indexPath!)
            self?.configureCell((self?.tableView.cellForRow(at: indexPath!))!, cellViewModel: cellViewModel!)
        }
        
        // Initialize static arrays for countryCode, countryName and countrieDictonary
        Countries.loadCountries()
    }
    

    // MARK: - Segues

    // NOTE: This demo uses Storyboards with Segues for navigation and relationship between view controllers.
    // This can also be done using a Coordinator based architecture / design pattern, for a more robust routing mechanism.
    // In this demo, UI Tests will cover the navigation relationship and Coordinator approach is left out of scope.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailEdit" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                userDetailViewController = segue.destination as? UserDetailViewController
                userDetailViewController?.managedObjectContext = self.managedObjectContext
                userDetailViewController?.userListViewController = self
                
                let userViewData = viewModel.getUserViewData(at: indexPath)
                userDetailViewController?.viewModel.load(userViewData: userViewData)

                userDetailViewController?.isAddMode = false
                userDetailViewController?.refreshDataControls()
            }
            
        } else if segue.identifier == "showDetailAdd" {
            userDetailViewController = segue.destination as? UserDetailViewController
            userDetailViewController?.managedObjectContext = self.managedObjectContext
            userDetailViewController?.userListViewController = self
            userDetailViewController?.isAddMode = true
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Only one section for Users list view
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let userViewData = viewModel.getCellViewModel(at: indexPath)
        configureCell(cell, cellViewModel: userViewData)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            _ = viewModel.deleteUser(indexPath: indexPath, context: managedObjectContext!)
            // TODO: Alert message if delete fails
        }
    }

    func configureCell(_ cell: UITableViewCell, cellViewModel: UserListCellViewModel) {
        cell.isAccessibilityElement = true
        cell.textLabel!.text = cellViewModel.name
        let text = formatDate(cellViewModel.dob)+" "+genderFromShortString(cellViewModel.gender)+" "+Countries.countriesDictonary[cellViewModel.cob]!
        cell.detailTextLabel!.text = text
    }

}
