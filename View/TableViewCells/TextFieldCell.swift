//
//  TextFieldCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

final class TextFieldCell: UITableViewCell {
    //MARK - Set Up Basic Text Field Cells; Set Cell Background Color in View Controllers
    
//    private var textFieldCellButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        //button.frame = CGRect(x: 4, y: 0, width: 40, height: 40)
//
//        //button.setImage(Images.PlusIcon, for: .normal)
//        button.setImage(SystemImages.Plus, for: .normal)
//        button.tintColor = Colors.tasksRed
//        button.imageView?.contentMode = .scaleAspectFit
//        return button
//    }()
    
    private var cellTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 5
        textField.layer.shadowColor = UIColor.systemGray.cgColor
        textField.layer.shadowRadius = 2.0
        textField.layer.borderWidth = 1.25
        textField.layer.borderColor = UIColor.systemGray.cgColor//UIColor.black.cgColor
        textField.tag = 0
        textField.adjustsFontForContentSizeCategory = true
        textField.font = DynamicFonts.HeadlineDynamic
//        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return textField
    }()
    private let addLabelIV: UIImageView = {
        let addImageView = UIImageView()
        addImageView.translatesAutoresizingMaskIntoConstraints = false
        addImageView.contentMode = .scaleAspectFit
        addImageView.tintColor = Colors.tasksRed
        addImageView.image = SystemImages.Plus
        return addImageView
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
//        cellTextField.addSubview(textFieldCellButton)
//        contentView.addSubview(cellTextField)
//
//        selectionStyle = .none
//        cellTextField.leftViewMode = .always
//        cellTextField.leftView = textFieldCellButton
        
        //textFieldCellButton.frame = CGRect(x: 0, y: 0, width: 40, height: contentView.frame.size.height)
        
        addConstraints()
        
    }
    
    private func addConstraints() {
        selectionStyle = .none
        
        backgroundColor = .secondarySystemBackground
        addSubview(addLabelIV)
        addSubview(cellTextField)
        //cellTextField.addSubview(textFieldCellButton)
//        cellTextField.leftViewMode = .always
//        cellTextField.leftView = textFieldCellButton

//        let guide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            addLabelIV.widthAnchor.constraint(equalToConstant: Constants.addImageWidth),
            addLabelIV.heightAnchor.constraint(equalTo: addLabelIV.widthAnchor),
            addLabelIV.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            addLabelIV.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            
            cellTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: addLabelIV.trailingAnchor, multiplier: 1),
            cellTextField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            cellTextField.topAnchor.constraint(equalToSystemSpacingBelow: safeAreaLayoutGuide.topAnchor, multiplier: 1),
            cellTextField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        
        ])
//        NSLayoutConstraint.activate([
//            //
//            addLabelIV.heightAnchor.constraint(equalTo: addLabelIV.widthAnchor),
//            addLabelIV.widthAnchor.constraint(equalToConstant: Constants.addImageWidth),
//            addLabelIV.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
//            addLabelIV.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
//
//            cellTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: addLabelIV.trailingAnchor, multiplier: 1),
//            cellTextField.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
////            cellTextField.centerYAnchor.constraint(equalTo: addLabelIV.centerYAnchor),
////            cellTextField.heightAnchor.constraint(equalToConstant: 30),
////            cellTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 250)
//
////            cellTextField.trailingAnchor.constraint(equalToSystemSpacingAfter: guide.trailingAnchor, multiplier: -4),
//            cellTextField.topAnchor.constraint(equalTo: guide.topAnchor),
//            cellTextField.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
////            cellTextField.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 0.5),
////            cellTextField.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
//        ])
        
//        cellTextField.leftViewMode = .always
//        cellTextField.leftView = UIView()
    }
    
    private func textFieldForIOS13() {
        if #available(iOS 13.0, *) {
            cellTextField.backgroundColor = .secondarySystemBackground
            //textFieldCellButton.backgroundColor = .secondarySystemBackground
            cellTextField.textColor = .label
        }
        else {
            cellTextField.backgroundColor = .white
            //textFieldCellButton.backgroundColor = .clear
            cellTextField.textColor = .black
        }
    }
    
    //MARK: - Configure View
    func configure(placeholder: CellPlaceholder, delegate: UITextFieldDelegate?, backgroundColor: UIColor) {
        self.cellTextField.placeholder = placeholder.rawValue
        self.cellTextField.delegate = delegate
    }
    
    func setTextFieldText(listTitle: String) {
        self.cellTextField.text = listTitle
    }
}

enum CellPlaceholder: String {
    case Title = "A New List"
    case Item = "A New Item"
}
