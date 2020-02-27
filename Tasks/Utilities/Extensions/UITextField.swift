//
//  UITextField.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func setTextFieldPlaceholder(placeHolderText: CellPlaceholder) {
        placeholder = placeHolderText.rawValue
        adjustsFontForContentSizeCategory = true
    }
  
    func handleTextFieldTheme() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextFieldThemeColors), name: .TasksThemeDidChange, object: nil)
    }
    
    @objc func handleTextFieldThemeColors() {
        if #available(iOS 13.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .light:
                
                setTextFieldBackgroundAndTextColors()
                
            case .dark:
                
                setTextFieldBackgroundAndTextColors()
                
            case .unspecified:
                print("Unspecified")
                
            @unknown default:
                fatalError()
            }
        }
    }
    
    func setTextFieldBackgroundAndTextColors() {
        backgroundColor = .label
        textColor = .label
    }
    
    
    
}




