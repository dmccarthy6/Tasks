//
//  TableThemeSettings.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

extension UITableView {
    
    func handleTableViewForIOS13() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTableViewTheme), name: .TasksThemeDidChange, object: nil)
    }
    
    
    @objc func handleTableViewTheme() {
        
        if #available(iOS 13.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .light:
                backgroundColor = .secondarySystemBackground
                return
                
            case .dark:
                backgroundColor = .secondarySystemBackground
                return
                
            case .unspecified:
                handleUnknown()
                
            @unknown default:
                handleUnknown()
            }
        }
    }
    
    func handleUnknown() {
        backgroundColor = .white
    }
    
}

