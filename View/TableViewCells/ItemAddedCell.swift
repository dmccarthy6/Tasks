//
//  ItemAddedCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

class ItemAddedCell: ItemsBaseCell {
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureItemsAddedCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set Up Items Cell
    func configureItemsAddedCell() {
        if #available(iOS 13.0, *) {
            completedButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
            completedButton.tintColor = Colors.tasksRed
            
            completedButton.backgroundColor = .systemBackground
            itemLabel.backgroundColor = .systemBackground
        }
        else {
            completedButton.setImage(Images.CheckBoxBlankRedIcon, for: .normal)
            
            completedButton.backgroundColor = .clear
            itemLabel.backgroundColor = .clear
        }
        
        selectionStyle = .none
        addSubview(completedButton)
        addSubview(itemLabel)
        addSubview(flaggedButton)
        setConstraints()
    }
    
    //MARK: - Set Layout Constraints
    func setConstraints() {
        completedButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: itemLabel.leadingAnchor, padding: .init(top: 5, left: 3, bottom: 5, right: 3), size: .init(width: 40, height: 40))
        itemLabel.anchor(top: safeAreaLayoutGuide.topAnchor, leading: completedButton.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: flaggedButton.leadingAnchor, padding: .init(top: 0, left: 3, bottom: 0, right: 1), size: .init(width: itemLabel.bounds.size.width, height: bounds.size.height))
        flaggedButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: itemLabel.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 5, right: 0), size: .init(width: 40, height: 40))
    }

}

