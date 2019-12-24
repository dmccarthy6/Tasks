//
//  ItemsBaseCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

class ItemsBaseCell: UITableViewCell {
    
    //MARK: - Button Tapped Functions
    var completionButtonFunc: (() -> (Void))!
    var flaggedButtonFunction: (() -> (Void))!
    
    //MARK: - UI Elements
    var completedButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    var itemLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = DynamicFonts.BodyDynamic
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    var flaggedButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    //MARK - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setButtonTargets()
        handleIOS13()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Button Functions
    func setButtonTargets() {
        completedButton.addTarget(self, action: #selector(checkedButtonTapped), for: .touchUpInside)
        flaggedButton.addTarget(self, action: #selector(flaggedButtonTapped), for: .touchUpInside)
    }
    
    @objc func checkedButtonTapped() {
        completionButtonFunc()
    }
    
    @objc func flaggedButtonTapped() {
        flaggedButtonFunction()
    }
    
    @objc func whenCompletedButtonTapped(_ function: @escaping () -> Void) {
        self.completionButtonFunc = function
    }
    
    @objc func whenFlaggedButtonTapped(_ function: @escaping () -> Void) {
        self.flaggedButtonFunction = function
    }
    
    //MARK: - Handle iOS 13.0
    func handleIOS13() {
        if #available(iOS 13.0, *) {
            completedButton.backgroundColor = .systemBackground
            flaggedButton.backgroundColor = .systemBackground
        }
        else {
            completedButton.backgroundColor = .clear
            flaggedButton.backgroundColor = .clear
        }
    }
}
