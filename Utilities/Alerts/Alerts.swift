//
//  Alerts.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

enum Alerts {
    
    //MARK: - BOOL Checking CK Enabled Status
    static private var suppressCloudKitEnabledError: Bool {
        get {
            return UserDefaults.standard.bool(forKey: CloudKitUserDefaultsKeys.SuppressCloudKitErrorKey.rawValue)
        }
    }
    
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
    
    static func customCloudKitError(errorMessage: String) {
        if !suppressCloudKitEnabledError {
            DispatchQueue.main.async {
                let cloudKitAlertController = UIAlertController(title: "iCloud", message: errorMessage, preferredStyle: .alert)
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
    
    static func editListActionSheet(title: List) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let configureListButton = UIAlertAction(title: "Edit List Title", style: .default) { (action) in
            
            let editListViewControler = EditListViewController()
            editListViewControler.list = title
            let navigationController = UINavigationController(rootViewController: editListViewControler)
            rootVC().present(navigationController, animated: true, completion: nil)
            
        }
        let shareButtonAction = UIAlertAction(title: "Share List", style: .default) { (action) in
            if let items = title.items?.allObjects as? [Items] {
                OpenShareExtension().showShareExtensionActionSheet(items: items)
            }
        }
        
        let cancelButtonAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(configureListButton)
        alertController.addAction(shareButtonAction)
        alertController.addAction(cancelButtonAction)
        
        rootVC().present(alertController, animated: true, completion: nil)
    }
    
    static func showAlert(_ viewController: UIViewController, message: String, okAction:( ()-> () )?) {
        Alerts.showAlertWithAction(viewController, title: "Error", message: message, okAction: okAction)
    }
    
    //MARK: - Text Field Alerts
    static func emptyTextFieldAlert(_ viewController: UIViewController, message: String) {
        Alerts.showAlertWithAction(viewController, title: "<#T##String#>", message: message, okAction: nil)
    }
    
    
    static func showSettingsAlert(_ viewController: UIViewController, message: String) {
        Alerts.showSettingsBasicAlert(viewController, title: "", message: message)
    }
    
    static func showNormalAlert(_ viewController: UIViewController, title: String, message: String) {
        Alerts.showAlertWithAction(viewController, title: title, message: message, okAction: nil)
    }
    
    //MARK: - CloudKit Errors
    
    static func showCloudKitErrorAlert(errorText: String) {
        Alerts.customCloudKitError(errorMessage: errorText)
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

enum CalendarAlertsMessage: String {
    case restricted = "Calendar access is restricted. Click settings to open the settings app and give Tasks access to your calendar."
    case eventAdded =  "Event has been added to your calendar"
    case eventExists = "Event already exists in your calendar."
    case eventNotAdded = "Error - Event has not been added to your calendar."
}

