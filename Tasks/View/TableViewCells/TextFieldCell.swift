//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

final class TextFieldCell: UITableViewCell {
    //MARK - Set Up Basic Text Field Cells; Set Cell Background Color in View Controllers
    
    private var cellTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 5
        textField.layer.shadowColor = UIColor.systemGray.cgColor
        textField.layer.shadowRadius = 2.0
        textField.tag = 0
        textField.adjustsFontForContentSizeCategory = true
        textField.font = .preferredFont(for: .title2, weight: .regular)
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
    
    private var cellTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.tag = 0
        textView.adjustsFontForContentSizeCategory = true
        textView.font = .preferredFont(for: .title2, weight: .regular)
        return textView
    }()
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        textFieldForIOS13()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout
    private func setupCell() {
        selectionStyle = .none
        
        backgroundColor = .secondarySystemBackground
        contentView.addSubview(addLabelIV)
        contentView.addSubview(cellTextField)


        let guide = contentView.layoutMarginsGuide

        NSLayoutConstraint.activate([
            addLabelIV.heightAnchor.constraint(equalTo: addLabelIV.widthAnchor),
            addLabelIV.widthAnchor.constraint(equalToConstant: Constants.addImageWidth),
            addLabelIV.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            addLabelIV.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
 
            cellTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: addLabelIV.trailingAnchor, multiplier: 1),
            cellTextField.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            cellTextField.centerYAnchor.constraint(equalTo: addLabelIV.centerYAnchor),
            cellTextField.topAnchor.constraint(equalTo: guide.topAnchor),
            cellTextField.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
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
    
    //MARK: - Interface
    
    ///Sets the placeholder for the textField and the delegate to respond to user interactions on the textfield.
    /// - Parameters:
    ///     - placeholder: Enum value setting the text
    ///     - delegate: Setting the textfield delegate
    func configure(placeholder: CellPlaceholder, delegate: UITextFieldDelegate?) {
        self.cellTextField.placeholder = placeholder.rawValue
        self.cellTextField.delegate = delegate
    }
    
    ///Sets the textField text to the Item or List being edited.
    /// - Parameters:
    ///     - listTitle: String value of the edited
    func setTextFieldText(listTitle: String) {
        self.cellTextField.text = listTitle
    }
}

/// Enum that sets the placeholder text for the text field.
enum CellPlaceholder: String {
    case Title = "A New List"
    case Item = "A New Item"
    
    
}
