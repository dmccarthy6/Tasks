//
//  TextFieldValidation.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import TasksFramework

final class ValidateTextField: NSObject, CanWriteToDatabase {
    
    public static let shared = ValidateTextField()
    
    func validateAndSave(_ viewController: UIViewController, textField: UITextField, title: String?, item: String?, list: List?, order: Int) {
        let validationResult = validateTextField(textField)
        if let errorMessage = validationResult.errorMessage {
            Alerts.textFieldIsEmptyAlert(viewController, message: errorMessage) {
                if let safeInputView = validationResult.inputView {
                    safeInputView.becomeFirstResponder()
                }
            }
        }
        else {
            if let title = title {
                saveObjectToCoreData(value: title, order: order, entity: .List, parent: nil)
            }
            if let item = item, let list = list {
                saveObjectToCoreData(value: item, order: order, entity: .Items, parent: list)
            }
        }
    }
    
    private func validateTextField(_ textField: UITextField) -> (errorMessage: String?, inputView: UIView?) {
        let errorMessage = "Enter text to add a list title or item"
        guard let textFieldText = textField.text else {
            return (errorMessage, textField)
        }
        if textFieldText.isEmpty {
            return (errorMessage, textField)
        }
        return (nil, nil)
    }
}
