//
//  CompletedButtonCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

class CompletedButtonCell: UITableViewCell {
    //MARK: - Properties
    fileprivate var completedButtonFunction: ( ()-> (Void) )!
    
    private var showCompletedButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.systemBackground.cgColor//UIColor.black.cgColor
        button.layer.cornerRadius = 10   //was 6
        button.contentEdgeInsets = UIEdgeInsets(top: 1, left: 7, bottom: 1, right: 7)
        button.backgroundColor = Colors.tasksRed
        button.titleLabel?.textColor = .label
        button.setTitle("Show Completed", for: .normal)
        return button
    }()
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        createShowCompletedButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("CompletedButtonCell - init(coder:) has not been implemented")
    }
    
    //MARK: -
    private func createShowCompletedButton() {
        selectionStyle = .none
        addSubview(showCompletedButton)
        showCompletedButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addConstraints()
    }
    
    private func addConstraints() {
        showCompletedButton.centerView(centerX: safeAreaLayoutGuide.centerXAnchor, centerY: safeAreaLayoutGuide.centerYAnchor, size: .init(width: showCompletedButton.bounds.size.width, height: 40), padding: .init(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    //MARK: - Button Functions
    @objc public func whenShowCompletedTapped(_ function: @escaping () -> Void) {
        self.completedButtonFunction = function
    }
    
    @objc private func buttonTapped() {
        completedButtonFunction()
    }
    
    func createShowCompletedButton(withTitle: CompletedButtonTitle) {
        //Set Button Title
        showCompletedButton.setTitle(withTitle.rawValue, for: .normal)
        createShowCompletedButton()
    }
    
    
    
}
