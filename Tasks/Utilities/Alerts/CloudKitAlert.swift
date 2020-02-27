//
//  CloudKitAlert.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

enum Alert {

        
        //MARK: - BOOL Checking CK Enabled Status
        static private var suppressCloudKitEnabledError: Bool {
            get {
                return UserDefaults.standard.bool(forKey: CloudKitUserDefaultsKeys.SuppressCloudKitErrorKey.rawValue)
            }
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
                    let cloudKitAlertController = UIAlertController(title: "iCloud Error", message: errorMessage, preferredStyle: .alert)
                    let OKButton = CloudKitPromptButtonType.OK
                    let OKButtonAction = UIAlertAction(title: OKButton.rawValue, style: OKButton.actionStyle()) { (okAction: UIAlertAction) in
                        OKButton.performAction()
                    }
                    
                    let dontShowAgainButton = CloudKitPromptButtonType.DontShowAgain
                    let dontShowAgainAction = UIAlertAction(title: dontShowAgainButton.rawValue, style: dontShowAgainButton.actionStyle()) { (action    ) in
                        dontShowAgainButton.performAction()
                    }
                    
                    cloudKitAlertController.addAction(OKButtonAction)
                    cloudKitAlertController.addAction(dontShowAgainAction)
                    
                    if let appDelegate = UIApplication.shared.delegate, let appWindow = appDelegate.window!, let rootViewController = appWindow.rootViewController {
                        rootViewController.present(cloudKitAlertController, animated: true, completion: nil)
                    }
                }
            }
            
        }

        
        //MARK: - CloudKit Errors
        
        static func showCloudKitErrorAlert(errorText: String) {
            Alert.customCloudKitError(errorMessage: errorText)
        }
    }

//    enum CalendarAlertsMessage: String {
//        case restricted = "Calendar access is restricted. Click settings to open the settings app and give Tasks access to your calendar."
//        case eventAdded =  "Event has been added to your calendar"
//        case eventExists = "Event already exists in your calendar."
//        case eventNotAdded = "Error - Event has not been added to your calendar."
//    }

enum CloudKitPromptButtonType: String {
    case OK = "OK"
    case DontShowAgain = "Don't Show Again"
    
    func performAction() {
        switch self {
        case .OK:
            break
        case .DontShowAgain:
            UserDefaults.standard.set(true, forKey: CloudKitUserDefaultsKeys.SuppressCloudKitErrorKey.rawValue)
            
        }
    }
    
    func actionStyle() -> UIAlertAction.Style {
        switch self {
        case .DontShowAgain: return .destructive
        default: return .default
        }
    }
}

enum CloudKitUserDefaultsKeys: String {
    
    case CloudKitEnabledKey = "CloudKitEnabledKey"
    case SuppressCloudKitErrorKey = "SuppressCloudKitErrorKey"
    case LastCloudKitSyncTimestamp = "LastCloudKitSyncTimestamp"
}

