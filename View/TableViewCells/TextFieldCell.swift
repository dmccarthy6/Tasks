//
//  TextFieldCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

class TextFieldCell: UITableViewCell {
    //MARK - Set Up Basic Text Field Cells; Set Cell Background Color in View Controllers
    
    private var textFieldCellButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 3, y: 0, width: 40, height: 40))
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private var cellTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 7
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.tag = 0
        textField.adjustsFontForContentSizeCategory = true
        textField.font = DynamicFonts.BodyDynamic
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return textField
    }()

    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createTextFieldCell()
        textFieldForIOS13()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set Up UI
    private func createTextFieldCell() {
        contentView.addSubview(cellTextField)
        cellTextField.addSubview(textFieldCellButton)
        selectionStyle = .none
        textFieldCellButton.setImage(Images.PlusIcon, for: .normal)
        cellTextField.leftViewMode = .always
        cellTextField.leftView = textFieldCellButton
        addConstraints()
    }
    
    private func addConstraints() {
        cellTextField.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 1, bottom: 0, right: 1), size: .init(width: bounds.size.width, height: bounds.size.height))
    }
    
    private func textFieldForIOS13() {
        if #available(iOS 13.0, *) {
            cellTextField.backgroundColor = .tertiarySystemBackground
            textFieldCellButton.backgroundColor = .tertiarySystemBackground
            cellTextField.textColor = .label
        }
        else {
            cellTextField.backgroundColor = .white
            textFieldCellButton.backgroundColor = .clear
            cellTextField.textColor = .black
        }
    }
    
    func configure(placeholder: CellPlaceholder, delegate: UITextFieldDelegate?, backgroundColor: UIColor) {
        self.cellTextField.placeholder = placeholder.rawValue
        self.cellTextField.delegate = delegate
        self.cellTextField.backgroundColor = backgroundColor
    }
    
    func setTextFieldText(listTitle: String) {
        self.cellTextField.text = listTitle
    }
}

enum CellPlaceholder: String {
    case Title = "A New List"
    case Item = "A New Item"
}
