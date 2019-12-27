//
//  EditItemCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

class EditItemCell: UITableViewCell {
    //MARK: - Properties
    private let editListTitleTextField: UITextField = {
        let addTitleTextField = UITextField()
        addTitleTextField.font = DynamicFonts.Title1Dynamic
        addTitleTextField.adjustsFontForContentSizeCategory = true
        return addTitleTextField
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
    func createEditItemCell() {
        addSubview(editListTitleTextField)
        addConstraints()
    }
    
    func addConstraints() {
        editListTitleTextField.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 2, bottom: 0, right: 0), size: .init(width: bounds.size.width, height: cellHeight)) //bounds.size.height
    }
    
    func configure(text: String, delegate: UITextFieldDelegate?) {
        editListTitleTextField.text = text
        editListTitleTextField.delegate = delegate
        editListTitleTextField.borderStyle = .roundedRect
    }
}

