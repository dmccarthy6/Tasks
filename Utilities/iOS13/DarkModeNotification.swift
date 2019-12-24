//
//  DarkModeNotification.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

extension UIView {
    
    @objc func handleViewThemeChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChange), name: .TasksThemeDidChange, object: nil)
    }
    
    
    @objc func handleThemeChange() {
        
        if #available(iOS 13.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .light:
                enableLightMode()
            case .dark:
                enableDarkMode()
            case .unspecified:
                handleOlderOS()
                
            @unknown default:
                fatalError()
            }
        }
        else {
            handleOlderOS()
        }
    }
    
    @objc func enableLightMode() {
        backgroundColor = .systemBackground
    }
    
    @objc func enableDarkMode() {
        backgroundColor = .systemBackground
    }
    
    @objc func handleOlderOS() {
        backgroundColor = .white
    }
    
    
//    func getView(from view: UIView) -> UIView {
//        if view.isKind(of: UILabel.self) {
//            let label = view as! UILabel
//            label.textColor = .label
//            return label
//        }
//    }
}

extension Notification.Name {
    static let TasksThemeDidChange = Notification.Name("TasksThemeDidChangeNotification")
}
