//
//  UILabel.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

extension UILabel {
    
    
    static func handleLabelThemeForIOS13() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLabelThemeColors), name: .TasksThemeDidChange, object: nil)
    }
    
    @objc func handleLabelThemeColors() {
        switch traitCollection.userInterfaceStyle {
        case .light:
            setBackgroundAndTextColor()
            
        case .dark:
            setBackgroundAndTextColor()
            
        case .unspecified:
            print("Unspecified")
            
        @unknown default:
            fatalError()
        }
    }
    
    private func setBackgroundAndTextColor() {
        if #available(iOS 13.0, *) {
            backgroundColor = .secondarySystemBackground
            textColor = .label
        }
        else {
            backgroundColor = .white
            textColor = .black
        }
    }
    
    
}

