//
//  AppDelegate.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import TasksFramework
import CloudKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coreDataManager: CoreDataManager?
    var notificationCenter: NotificationCenter?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let mainListVC = ListsViewController()
        
        let navigationController = UINavigationController(rootViewController: mainListVC)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        let viewController = window?.visibleViewController()
        checkCloudStatusFor(rootViewController: viewController!)
        
        coreDataManager = CoreDataManager() {
            [unowned self] in
            self.setCoreDataManagerInViews()
        }
        application.registerForRemoteNotifications()
        setNavigationBarColors()
        return true
    }
    
    func checkCloudStatusFor(rootViewController: UIViewController) {
        CKContainer.default().accountStatus { (cloudStatus, error) in
            switch cloudStatus {
            case .available: return
            case .noAccount: Alerts.customCloudKitError(errorMessage: "You are not logged into iCloud. Click settings to enable iCloud for Tasks in order to keep all your devices updated.")
            case .restricted: Alerts.customCloudKitError(errorMessage: "iCloud account is restricted for this content. Click on settings below to update your iCloud settings.")
            case .couldNotDetermine: Alerts.customCloudKitError(errorMessage: "Unable to determine iCloud status. Click settings to log into iCloud.")
            @unknown default: return
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: []) { (granted, error) in
            
            if let error = error {
                print("Error Granting Push Notifications - \(error.localizedDescription)")
            }
            print("Remote Notification Permission Granted? - \(granted)")
        }
    }
    
    func setNavigationBarColors() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = .white
        navigationBarAppearance.barTintColor = Colors.tasksRed
        
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    //MARK: - Share Extension, open app functions:
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        //When Share Passed to Your App
        print("App Delegate = \(url)")
        return false
    }
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "tasksopen" {
            print("AppDel - Yes!")
            
            if url.host == "addItemsVC" {
                let containerDefaults = UserDefaults(suiteName: "group.Tasks.Extensions")
                let id = containerDefaults?.data(forKey: "tappedID")
                
                do {
                    let idDecoded = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSString.self], from: id!) as! String
                    let addItemsVC = AddItemsToListViewController()
                    let navController = UINavigationController(rootViewController: addItemsVC)
                    //addItemsVC.id = idDecoded
                    window?.rootViewController = navController
                }
                catch let error as NSError {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
        let sendingAppID = options[.sourceApplication]
        print("AppDelegate = SourceApplication = \(sendingAppID ?? "AppDel, Unknown Source App"), url: \(url)")
        return true
    }
    
    //MARK: - Set Core Data Manager
    /*
     This may not be needed anymore
     */
    func setCoreDataManagerInViews() {
        guard let safeCoreDataManager = coreDataManager else {
            fatalError("AppDelegate - Error - Cant Unwrap CoreDataManager")
        }
        let navigationController = window?.rootViewController as! UINavigationController
        let viewControllers = navigationController.viewControllers
        
        for viewController in viewControllers {
            switch viewController {
            case let navigationController as UINavigationController:
                if var rootViewController: CoreDataManagerViewController = navigationController.viewControllers[0] as? CoreDataManagerViewController {
                    rootViewController.coreDataManager = safeCoreDataManager
                }
            default: ()
            }
        }
    }

}
