//
//  CompletedItemsCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

class CompletedItemsCell: UITableViewCell, CanWriteToDatabase {
    
    //MARK: - Properties
    var itemLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = DynamicFonts.BodyDynamic
        label.backgroundColor = .systemBackground
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    var completedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(SystemImages.CircleWithCheck, for: .normal)
        button.tintColor = Colors.tasksRed
        button.backgroundColor = .systemBackground
        
        return button
    }()
    
    var flaggedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(SystemImages.Star, for: .normal)
        button.backgroundColor = .systemBackground
        button.tintColor = Colors.tasksRed
        
        return button
    }()
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createCompletedTasksCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set Up Completed Cell And Completed Button
    private func createCompletedTasksCell() {
        if #available(iOS 13.0, *) {
            completedButton.tintColor = Colors.tasksRed
            completedButton.backgroundColor = .systemBackground
            itemLabel.backgroundColor = .systemBackground
        }
        else {
            completedButton.setImage(Images.CompletedTasksIcon, for: .normal)
            completedButton.tintColor = Colors.tasksRed
            completedButton.backgroundColor = .clear
            itemLabel.backgroundColor = .clear
        }
        selectionStyle = .none
        
        setupLayout()
    }

    //MARK: - Set Cell Constraints
    private func setupLayout() {
        contentView.addSubview(completedButton)
        contentView.addSubview(itemLabel)
        contentView.addSubview(flaggedButton)
        
        let guide = contentView.layoutMarginsGuide
        
//        NSLayoutConstraint.activate([
//            completedButton.widthAnchor.constraint(equalToConstant: 40),
//            completedButton.heightAnchor.constraint(equalTo: completedButton.widthAnchor),
//            completedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
//            completedButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
//
//            itemLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: completedButton.trailingAnchor,
//                                               multiplier: 5),
//            itemLabel.trailingAnchor.constraint(equalTo: flaggedButton.leadingAnchor),
//            itemLabel.topAnchor.constraint(equalTo: guide.topAnchor),
//            itemLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
//
//            flaggedButton.widthAnchor.constraint(equalToConstant: 40),
//            flaggedButton.heightAnchor.constraint(equalTo: flaggedButton.widthAnchor),
//            flaggedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
//            flaggedButton.leadingAnchor.constraint(equalToSystemSpacingAfter: itemLabel.trailingAnchor,
//                                                   multiplier: 5)
//
//        ])
        
        
        completedButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: itemLabel.leadingAnchor, padding: .init(top: 5, left: 3, bottom: 5, right: 0), size: .init(width: 40, height: 40))
        itemLabel.anchor(top: safeAreaLayoutGuide.topAnchor, leading: completedButton.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: flaggedButton.leadingAnchor, padding: .init(top: 0, left: 3, bottom: 0, right: 1), size: .init(width: itemLabel.bounds.size.width, height: bounds.size.height))
        flaggedButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: itemLabel.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 5, right: 7), size: .init(width: 40, height: 40))
        
        flaggedButton.addTarget(self, action: #selector(flaggedButtonTapped), for: .touchUpInside)
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
    }
 
    
    func configure(item: String) {
        self.itemLabel.text = item
    }
    
    func handleCompletedFlaggedAndCompletedButtonTapped(for item: Items, controller: ItemsController, isFlagged: Bool, isComplete: Bool, tableView: UITableView) {
        
        whenFlaggedButtonTapped {
            self.setItemAsFlagged(item: item, status: !isFlagged)
            self.flaggedButton.setImage((isFlagged ? SystemImages.Star : SystemImages.StarFill), for: .normal)
            self.flaggedButton.tintColor = isFlagged ? Colors.tasksRed : Colors.tasksYellow
            tableView.reloadData()
        }
        
        whenCompletedButtonTapped {
            self.setItemCompletedStatus(item: item)
            tableView.reloadData()
        }
    }
    
    func showing(controller: ItemsController, currentIsShowing: Bool) -> Bool {
        if controller.getCompletedItemsCount() == 0 {
            return false
        }
        return currentIsShowing
    }
    
    //MARK: - Button Functions
    private var completedButtonFunc: (() -> (Void))!
    private var flaggedButtonFunc: (() -> (Void))!
    
    @objc func completedButtonTapped() {
        completedButtonFunc()
    }
    
    @objc func flaggedButtonTapped() {
        flaggedButtonFunc()
    }
    
    @objc func whenCompletedButtonTapped(_ function: @escaping () -> Void) {
        self.completedButtonFunc = function
    }
    
    @objc func whenFlaggedButtonTapped(_ function: @escaping () -> Void) {
        self.flaggedButtonFunc = function
    }
    
}

/*
 OLD CELL
 class CompletedItemsCell: ItemsBaseCell {
     //MARK: - Initializers
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         createCompletedTasksCell()
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     //MARK: - Set Up Completed Cell And Completed Button
     private func createCompletedTasksCell() {
         if #available(iOS 13.0, *) {
             completedButton.setImage(SystemImages.CircleWithCheck, for: .normal)
             completedButton.tintColor = Colors.tasksRed
             completedButton.backgroundColor = .systemBackground
             itemLabel.backgroundColor = .systemBackground
         }
         else {
             completedButton.setImage(Images.CompletedTasksIcon, for: .normal)
             completedButton.tintColor = Colors.tasksRed
             completedButton.backgroundColor = .clear
             itemLabel.backgroundColor = .clear
         }
         selectionStyle = .none
         addSubview(completedButton)
         addSubview(itemLabel)
         addSubview(flaggedButton)
         setConstraints()
     }

     //MARK: - Set Cell Constraints
     private func setConstraints() {
         completedButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: itemLabel.leadingAnchor, padding: .init(top: 5, left: 3, bottom: 5, right: 0), size: .init(width: 40, height: 40))
         itemLabel.anchor(top: safeAreaLayoutGuide.topAnchor, leading: completedButton.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: flaggedButton.leadingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 1), size: .init(width: itemLabel.bounds.size.width, height: bounds.size.height))
         flaggedButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: itemLabel.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 5, right: 0), size: .init(width: 40, height: 40))
     }
  
     
     func configure(item: String) {
         self.itemLabel.text = item
     }
     
     func handleCompletedFlaggedAndCompletedButtonTapped(for item: Items, controller: ItemsController, isFlagged: Bool, isComplete: Bool, tableView: UITableView) {
         
         whenFlaggedButtonTapped {
             self.setItemAsFlagged(item: item, status: !isFlagged)
             self.flaggedButton.setImage((isFlagged ? SystemImages.Star : SystemImages.StarFill), for: .normal)
             self.flaggedButton.tintColor = isFlagged ? Colors.tasksRed : Colors.tasksYellow
             tableView.reloadData()
         }
         
         whenCompletedButtonTapped {
             self.setItemCompletedStatus(item: item)
         }
     }
     
     
 }
 */


