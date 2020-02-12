
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import UserNotifications
import TasksFramework
import CloudKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CanWriteToDatabase {
    var window: UIWindow?
    var notificationCenter: NotificationCenter?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let mainListVC = ListsViewController()
        
        let navigationController = UINavigationController(rootViewController: mainListVC)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        let viewController = window?.visibleViewController()
        registerForPushNotifications(application: application)
        checkCloudStatusFor(rootViewController: viewController!)
        setNavigationBarColors()
        return true
    }
    
    //MARK: - Helper Methods
    /* Presents alert to user if they are not currently logged into CloudKit. Gives them option to open settings and log into iCloud to sync lists between devices. */
    func checkCloudStatusFor(rootViewController: UIViewController) {
        CKContainer.default().accountStatus { (cloudStatus, error) in
            switch cloudStatus {
            case .available: return
            case .noAccount: Alerts.customCloudKitError(errorMessage: CloudKitErrorMessage.noAccount)
            case .restricted: Alerts.customCloudKitError(errorMessage: CloudKitErrorMessage.restricted)
            case .couldNotDetermine: Alerts.customCloudKitError(errorMessage: CloudKitErrorMessage.couldNotDetermine)
            @unknown default: return
            }
        }
    }
    
    //Reigster For Push Notifications
    func registerForPushNotifications(application: UIApplication) {
        if application.isRegisteredForRemoteNotifications { return }
        else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .providesAppNotificationSettings]) { (granted, error) in
                if error == nil && granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
                else {
                    //Permission Denied
                }
            }
        }
    }
    
    //UI - Setting Navigation Bar Appearance
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
    
    //MARK: - Today Widget - called when user taps item in Today Widgetm this opens the correct ItemsController.
    /*Function used when user opens the application from the Today Widget */
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "tasksopen" {
            
            if url.host == "addItemsVC" {
                let containerDefaults = UserDefaults(suiteName: "group.Tasks.Extensions")
                let id = containerDefaults?.data(forKey: "tappedID")
                
                do {
                    if let id = id {
                        let encodedID = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSString.self], from: id) as! String
                        openItemsController(for: encodedID)
                    }
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
  
    func openItemsController(for listID: String) {
        let navigationController = UINavigationController()
        let rootVC = ListsViewController()
        let itemsVC = AddItemsToListViewController()
        itemsVC.listTitleID = listID
        navigationController.setViewControllers([rootVC, itemsVC], animated: true)
        window?.rootViewController = navigationController
        
    }

}
