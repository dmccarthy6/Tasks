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
        textField.font = DynamicFonts.Title1Dynamic
        textField.textColor = .label
        textField.adjustsFontForContentSizeCategory = true
        textField.backgroundColor = .secondarySystemBackground
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
        
        editListTitleTextField.anchor(top: safeAreaLayoutGuide.topAnchor,
                                      leading: safeAreaLayoutGuide.leadingAnchor,
                                      bottom: safeAreaLayoutGuide.bottomAnchor,
                                      trailing: safeAreaLayoutGuide.trailingAnchor,
                                      padding: .init(top: 0, left: 40, bottom: 0, right: 40),
                                      size: .init(width: bounds.size.width, height: cellHeight)) //bounds.size.height
        backgroundColor = .systemBackground
    }
    
    //MARK: - Interface Function
    func configure(text: String, delegate: UITextFieldDelegate?) {
        editListTitleTextField.text = text
        editListTitleTextField.delegate = delegate
        editListTitleTextField.borderStyle = .roundedRect
        editListTitleTextField.becomeFirstResponder()
    }
}

