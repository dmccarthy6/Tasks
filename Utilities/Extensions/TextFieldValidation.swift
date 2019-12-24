//
//  TextFieldValidation.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

class ValidateTextField: NSObject, CanWriteToDatabase {
    
    public static let shared = ValidateTextField()
    
    func validateAndSave(_ viewController: UIViewController, textField: UITextField, title: String?, item: String?, list: List?, order: Int) {
        let validationResult = validateTextField(textField)
        if let errorMessage = validationResult.errorMessage {
            Alerts.showAlert(viewController, message: errorMessage) {
                if let safeInputView = validationResult.inputView {
                    safeInputView.becomeFirstResponder()
                }
            }
        }
        else {
            if let title = title {
                saveObjectToCoreData(value: title, order: order, entity: .List, parent: nil)
                //CoreDataManager.shared.saveTitleToCoreData(title: title!)
            }
            if let item = item, let list = list {
                //CoreDataManager.shared.saveItemsToCoreData(item: item!)
                saveObjectToCoreData(value: item, order: order, entity: .Items, parent: list)
            }
        }
    }
    
    private func validateTextField(_ textField: UITextField) -> (errorMessage: String?, inputView: UIView?) {
        let errorMessage = "Text Field Can Not Be Empty"
        guard let textFieldText = textField.text else {
            return (errorMessage, textField)
        }
        if textFieldText.isEmpty {
            return (errorMessage, textField)
        }
        return (nil, nil)
    }
}
