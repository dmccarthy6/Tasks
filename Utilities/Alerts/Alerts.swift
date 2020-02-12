
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//


import UIKit
import TasksFramework

enum Alerts {
    
    //MARK: - BOOL Checking CK Enabled Status
    static private var suppressCloudKitEnabledError: Bool {
        get {
            return UserDefaults.standard.bool(forKey: CloudKitUserDefaultsKeys.SuppressCloudKitErrorKey.rawValue)
        }
    }
    
    //MARK: - Convenience Funtions
    /* These are the functions that get called in their respective ViewControllers. Real alert controller functions are below. */
    //MARK: - CloudKit Alert
    static func showCloudKitErrorAlert(errorText: CloudKitErrorMessage) {
        Alerts.customCloudKitError(errorMessage: errorText)
    }
    
    //MARK: - Text Field Alerts
    static func textFieldIsEmptyAlert(_ viewController: UIViewController, message: String, okAction:( ()-> () )?) {
        Alerts.showAlertWithAction(viewController, title: "Empty Text Field", message: message, okAction: okAction)
    }
    
    static func deleteAlert(_ viewController: UIViewController, view: UIView, message: DeleteAlertMessage, deleteAction:( () -> ())?) {
        Alerts.deleteAlertWithDeleteAction(viewController, view: view, message: message, deleteAction: deleteAction)
    }
    
    static func showSettingsAlert(_ viewController: UIViewController, message: String) {
        Alerts.showSettingsBasicAlert(viewController, title: "", message: message)
    }
    
    
    
    /* This is called when user trys to add empty text to a list or an item. Alerts them no empty data is allowed. */
    static func showAlertWithAction(_ vc: UIViewController, title: String, message: String, okAction:( () -> () )?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let safeOkAction = okAction { safeOkAction() }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async { vc.present(alertController, animated: true, completion: nil) }
    }
    
    /* Called when user is not logged into Calendar, brings them to settings if needed */
    static func showSettingsBasicAlert(_ vc: UIViewController, title: String, message: String) {
        let settingsAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let openSettingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: { (success) in
                    print("Opened Settings, Success!")
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        settingsAlertController.addAction(openSettingsAction)
        settingsAlertController.addAction(cancelAction)
        DispatchQueue.main.async { vc.present(settingsAlertController, animated: true, completion: nil) }
    }
    
    //MARK: - Delete Alert
    /* This alert is called in ListsViewController when user selects to delete a list */
    static func deleteAlertWithDeleteAction(_ viewController: UIViewController, view: UIView, message: DeleteAlertMessage, deleteAction:( () -> () )?) {
        let alertController = UIAlertController(title: "Delete", message: message.message, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            if let safeDeleteAction = deleteAction { safeDeleteAction() }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
        }
        DispatchQueue.main.async { viewController.present(alertController, animated: true) }
    }
    
    //MARK: - Action Sheets
    /* The edit list action sheet is called when the user hits the 'edit list' navigation button. Action sheet shows with two options:
     * Edit List - Passes the edit list VC modally.
     * Share List - Action sheet shows with share extension.
     */
    static func editListActionSheet(title: List, popoverBarItem: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let configureListButton = UIAlertAction(title: "Edit List Title", style: .default) { (action) in
            
            let editListViewControler = EditListViewController()
            editListViewControler.list = title
            let navigationController = UINavigationController(rootViewController: editListViewControler)
            rootVC().present(navigationController, animated: true, completion: nil)
            
        }
        let shareButtonAction = UIAlertAction(title: "Share List", style: .default) { (action) in
            if let items = title.items?.allObjects as? [Items] {
                OpenShareExtension().showShareExtensionInItemsActionSheet(items: items, popoverItem: popoverBarItem)
            }
        }
        
        let cancelButtonAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(configureListButton)
        alertController.addAction(shareButtonAction)
        alertController.addAction(cancelButtonAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = popoverBarItem
        }
        rootVC().present(alertController, animated: true, completion: nil)
    }
    
    static func shareListActionSheet(_ viewController: UIViewController, items: [Items], popoverView: UIView) {
        let alertController = UIAlertController(title: "Share List", message: nil, preferredStyle: .actionSheet)
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { (action) in
            OpenShareExtension().showShareExtensionInList(viewController, items: items, popoverView: popoverView)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        
        if let popoverShareController = alertController.popoverPresentationController {
            popoverShareController.sourceView = popoverView
        }
        viewController.present(alertController, animated: true)
    }
    
    //MARK: - CloudKit Custom Alert
    /* This alert is called in App Delegate if user is not logged into CloudKit. Alerts user that without being logged in, lists won't be saved on all CK connected accounts/devices. */
    static func customCloudKitError(errorMessage: CloudKitErrorMessage) {
        if !suppressCloudKitEnabledError {
            DispatchQueue.main.async {
                let cloudKitAlertController = UIAlertController(title: "iCloud", message: errorMessage.message, preferredStyle: .alert)
                let OKButton = CloudKitPromptButtonType.OK
                let OKButtonAction = UIAlertAction(title: OKButton.rawValue, style: OKButton.actionStyle()) { (okAction: UIAlertAction) in
                    OKButton.performAction()
                }
                
                let dontShowAgainButton = CloudKitPromptButtonType.DontShowAgain
                let dontShowAgainAction = UIAlertAction(title: dontShowAgainButton.rawValue, style: dontShowAgainButton.actionStyle()) { (action    ) in
                    dontShowAgainButton.performAction()
                }
                
                let settingsButton = UIAlertAction(title: "Settings", style: .default) { (action) in
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(settingsURL) {
                        UIApplication.shared.open(settingsURL, options: [:]) { (success) in
                            print("Settings Opened Successfully")
                        }
                    }
                }
                
                cloudKitAlertController.addAction(OKButtonAction)
                cloudKitAlertController.addAction(settingsButton)
                cloudKitAlertController.addAction(dontShowAgainAction)
                
                if let appDelegate = UIApplication.shared.delegate, let appWindow = appDelegate.window!, let rootViewController = appWindow.rootViewController {
                    rootViewController.present(cloudKitAlertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    
    private static func rootVC() -> UIViewController {
        if let appDelegate = UIApplication.shared.delegate, let appWindow = appDelegate.window!, let rootViewController = appWindow.rootViewController {
            return rootViewController
        }
        else {
            return UIViewController()
        }
    }
    
    
}

//MARK: - Alerts Enums
enum CalendarAlertsMessage: String {
    case restricted = "Calendar access is restricted. Click settings to open the settings app and give Tasks access to your calendar."
    case eventAdded =  "Event has been added to your calendar"
    case eventExists = "Event already exists in your calendar."
    case eventNotAdded = "Error - Event has not been added to your calendar."
}

enum DeleteAlertMessage: String {
    
    case deleteList
    case deleteItems
    
    var message: String {
        switch self {
        case .deleteList: return "Are you sure you want to delete this list? Deleting this list will delete all items associated with the list."
        case .deleteItems: return "Are you sure you want to delete this item? "
        }
    }
}
