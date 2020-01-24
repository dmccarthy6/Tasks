//
//  EditItemCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

final class EditItemCell: UITableViewCell {
    //MARK: - Properties
    private let editListTitleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = DynamicFonts.Title1Dynamic
        textField.textColor = .label
        textField.adjustsFontForContentSizeCategory = true
        textField.backgroundColor = .secondarySystemBackground
        textField.borderStyle = .roundedRect
        return textField
    }()
    private var cellHeight: CGFloat = 60.0
    
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createEditItemCell()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Helper Functions
    private func createEditItemCell() {
        contentView.addSubview(editListTitleTextField)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            editListTitleTextField.topAnchor.constraint(equalTo: guide.topAnchor),
            editListTitleTextField.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            editListTitleTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: guide.leadingAnchor, multiplier: 0),
            editListTitleTextField.trailingAnchor.constraint(equalToSystemSpacingAfter: guide.trailingAnchor, multiplier: 0)
        ])
        backgroundColor = .systemBackground
    }
    
    //MARK: - Interface Function
    func configure(text: String, delegate: UITextFieldDelegate?) {
        editListTitleTextField.text = text
        editListTitleTextField.delegate = delegate
        editListTitleTextField.becomeFirstResponder()
    }
}

