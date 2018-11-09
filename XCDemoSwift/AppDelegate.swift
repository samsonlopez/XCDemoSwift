//
//  AppDelegate.swift
//  XCDemoSwift
//
//  Created by Samson Lopez on 28/10/2018.
//  Copyright © 2018 Samson Lopez. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set managedObjectContext in UserList and UserDetail view controllers as weak references, used in ViewModel/Model for CoreData.
        
        let tabBarController = self.window?.rootViewController as! UITabBarController
        let navigationController = tabBarController.viewControllers![0] as! UINavigationController
        let usersViewController = navigationController.topViewController as! UserListViewController
        usersViewController.managedObjectContext = self.persistentContainer.viewContext

        let submitViewController = tabBarController.viewControllers![1] as! SubmitViewController
        submitViewController.managedObjectContext = self.persistentContainer.viewContext

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "XCDemoSwift")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // TODO: Replace this to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: Replace this to handle the error appropriately.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
