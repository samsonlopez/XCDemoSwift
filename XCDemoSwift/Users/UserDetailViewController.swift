//
//  UserDetailViewController.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import UIKit
import CoreData

class UserDetailViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // ViewModel property for UserDetailViewController (MVVM Architecture)
    lazy var viewModel: UserDetailViewModel = {
        return UserDetailViewModel()
    }()
    
    // Child view controllers
    weak var userListViewController: UserListViewController!
    
    // Core data context
    weak var managedObjectContext: NSManagedObjectContext!

    
    // Interface builder bindings for input and display controls
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var cobTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!

    // Interface builder bindings for static table view cells
    @IBOutlet weak var nameTableViewCell: UITableViewCell!
    @IBOutlet weak var dobTableViewCell: UITableViewCell!
    @IBOutlet weak var genderTableViewCell: UITableViewCell!
    @IBOutlet weak var cobTableViewCell: UITableViewCell!
    
    var isAddMode: Bool = true
    weak var activeTextField: UITextField?
    
    var dobDatePicker: UIDatePicker!
    var gengerPickerView: UIPickerView!

    let dobDateFormatter = DateFormatter()

    // Interface builder bindings for actions

    @IBAction func saveButtonPress(_ sender: Any) {
        
        if let activeTextField =  self.activeTextField{
            activeTextField.resignFirstResponder()
        }
        
        var isSuccessfull = false
        
        // Validate all input fields before saving
        if viewModel.validateDataControls() {
            if let userViewData = viewModel.getUserViewData() {
                if isAddMode {
                    isSuccessfull = userListViewController.viewModel.addNewUser(userViewData: userViewData, context: managedObjectContext)
                } else {
                    if let indexPath = userListViewController.tableView.indexPathForSelectedRow {
                        isSuccessfull = userListViewController.viewModel.updateUser(userViewData: userViewData, indexPath:indexPath, context: managedObjectContext)
                    }
                }
            }
            if isSuccessfull {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This view serves the purpose of both Add and Edit, based on the mode set.
        if isAddMode {
            navigationItem.title = "Add User"
        } else {
            navigationItem.title = "Edit User"
        }
        
        // Delegate for name field
        nameTextField.delegate = self
        dobTextField.delegate = self
        genderTextField.delegate = self
        cobTextField.delegate = self
        
        // Set the date format for dob input field
        dobDateFormatter.dateFormat = "dd/MM/yyyy"

        // Picker for dob field
        dobDatePicker = UIDatePicker()
        dobDatePicker.datePickerMode = UIDatePicker.Mode.date
        dobDatePicker.date = Date()
        dobDatePicker.addTarget(self, action: #selector(updateDateField(_:)), for:.valueChanged)
        dobTextField.inputView = dobDatePicker
        
        // Picker for gender field
        gengerPickerView = UIPickerView()
        gengerPickerView.dataSource = self
        gengerPickerView.delegate = self
        genderTextField.inputView = gengerPickerView
        
        
        // Clousures Binding UI response actions to the ViewModel events for input validation.

        viewModel.validateNameClosure = { [weak self] (isValid: Bool) -> () in
            self?.setValidationError(forCell: (self?.nameTableViewCell)!, isValid: isValid)
        }

        viewModel.validateDobClosure = { [weak self] (isValid: Bool) -> () in
            self?.setValidationError(forCell: (self?.dobTableViewCell)!, isValid: isValid)
        }

        viewModel.validateGenderClosure = { [weak self] (isValid: Bool) -> () in
            self?.setValidationError(forCell: (self?.genderTableViewCell)!, isValid: isValid)
        }

        viewModel.validateCobClosure = { [weak self] (isValid: Bool) -> () in
            self?.setValidationError(forCell: (self?.cobTableViewCell)!, isValid: isValid)
        }
        
        viewModel.loadUserClosure = { [weak self] in
            self?.refreshDataControls()
        }

        viewModel.countryCodes = Countries.countryCodes
    }
    
    // Sets a validation error indicator against input field in the cell's accessory view
    func setValidationError(forCell cell: UITableViewCell, isValid: Bool) {
        let validationErrorImageView = UIImageView(image: UIImage(named: "alert.png"))

        if(isValid) {
            cell.accessoryView = nil
        } else {
            cell.accessoryView = validationErrorImageView
        }
    }
    
    // Date picker handler (for dob field)
    @objc func updateDateField(_ sender:UIDatePicker) {
        dobTextField.text = formatDate(dobDatePicker.date)
        viewModel.dob = dobDatePicker.date
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCountries" {
            let countryListViewController = segue.destination as? CountryListViewController
            countryListViewController?.userDetailViewController = self
        }
    }
    
    // Refresh input/display fields with changes in viewModel
    func refreshDataControls() {
        
        // Load view if not loaded
        let _ = self.view

        if let name = viewModel.name {
            nameTextField?.text = name
            print("name=\(name)")
        }
        
        if let dob = viewModel.dob {
            dobTextField.text = formatDate(dob)
            print("dob=\(dob.description)")
        }
        
        if let gender = viewModel.gender {
            genderTextField.text = genderFromShortString(gender)
            print("gender=\(gender)")
        }
        
        if let cob = viewModel.cob {
            cobTextField.text = Countries.countriesDictonary[cob]
            print("cob=\(cob)")
        }
    }
    
    // Handles input cob field passing it to the viewModel
    func setCountry(countryCode: String) {
        cobTextField.text = Countries.countriesDictonary[countryCode]
        viewModel.cob = countryCode
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField;        
    }
    
    // Handles input text fields, passing it to the viewModel
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (activeTextField == nameTextField) {
            // TODO: Trimming leading and trailing spaces and special characters here?
            viewModel.name = nameTextField.text
            
        } else if (activeTextField == dobTextField) {
            let date = dobDateFormatter.date(from: dobTextField.text!)
            viewModel.dob = date
            // Also updated via DataPicker
            
        } else if (activeTextField == genderTextField) {
            self.viewModel.gender = genderTextField.text
            // Also updated via PickerView
            
        } else if (activeTextField == cobTextField) {
            // Updated via CountryListViewController lookup
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - UIPickerViewDelegate (for Gender)

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTextField.text = genderFromIndex(row)
        viewModel.setGender(index:row)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderFromIndex(row)
    }
 
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2 // Two options for Gender (Male, Female)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // One row value for Gender pickupView
    }
    
}
