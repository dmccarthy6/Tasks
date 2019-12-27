//
//  CompletedButtonCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

class CompletedButtonCell: UITableViewCell {
    
    var completedButtonFunction: ( ()-> (Void) )!
    
    var showCompletedButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        button.backgroundColor = Colors.tasksRed
        button.setTitle("Show Completed", for: .normal)
        return button
    }()
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createShowCompletedButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    func createShowCompletedButton() {
        selectionStyle = .none
        addSubview(showCompletedButton)
        showCompletedButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addConstraints()
    }
    
    func addConstraints() {
        showCompletedButton.centerView(centerX: safeAreaLayoutGuide.centerXAnchor, centerY: safeAreaLayoutGuide.centerYAnchor, size: .init(width: showCompletedButton.bounds.size.width, height: 30), padding: .init(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    //MARK: - Button Functions
    @objc func whenShowCompletedTapped(_ function: @escaping () -> Void) {
        self.completedButtonFunction = function
    }
    
    @objc func buttonTapped() {
        completedButtonFunction()
    }
    
    func configure(isCompletedShowing: Bool, tableView: UITableView) {
        whenShowCompletedTapped {
            <#code#>
        }
    }
}
