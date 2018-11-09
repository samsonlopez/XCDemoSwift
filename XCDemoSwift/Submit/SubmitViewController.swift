//
//  SubmitViewController.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import UIKit
import CoreData

class SubmitViewController: UIViewController {
    
    lazy var viewModel: SubmitViewModel = {
        return SubmitViewModel(dataService: DataService(), managedObjectContext: self.managedObjectContext!)
    }()

    weak var managedObjectContext: NSManagedObjectContext!
    var isSubmitInProgress = false

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var submitActivityView: UIActivityIndicatorView!
    @IBOutlet weak var submitLabel: UILabel!
    
    @IBAction func submitButtonPress(_ sender: Any) {
        if !isSubmitInProgress {
            isSubmitInProgress = true
            submitLabel.isHidden = false
            submitLabel.text = "Submitting..."
            
            submitActivityView.isHidden = false
            submitActivityView.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            viewModel.submit { [weak self] (success, error) in
                DispatchQueue.main.sync {
                    // Note: The logic here is not moved to the viewModel to keep it simple as there is no validation requirement.
                    if success {
                        self?.submitLabel.text = "Submission Successfull!"
                    } else {
                        self?.submitLabel.text = "Submission Failed!"
                    }
                    self?.submitActivityView.isHidden = true
                    self?.submitActivityView.stopAnimating()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitLabel.isHidden = true
        submitActivityView.isHidden = true
    }
    
}
