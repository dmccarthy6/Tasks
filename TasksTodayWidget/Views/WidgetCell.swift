
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import TasksFramework

class WidgetCell: UITableViewCell {
    
    private var completedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.CircleBlank, for: .normal)
        button.tintColor = Colors.tasksRed
        return button
    }()
    
    private var itemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private var flaggedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.Star!, for: .normal)
        button.tintColor = Colors.tasksRed
        return button
    }()
    
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    private func setupCell() {
        contentView.addSubview(completedButton)
        contentView.addSubview(itemLabel)
        contentView.addSubview(flaggedButton)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            completedButton.widthAnchor.constraint(equalToConstant: 40),
            completedButton.heightAnchor.constraint(equalTo: completedButton.widthAnchor),
            completedButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            completedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            
            itemLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: completedButton.trailingAnchor, multiplier: 1),
            itemLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            itemLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            
            flaggedButton.widthAnchor.constraint(equalToConstant: 40),
            flaggedButton.heightAnchor.constraint(equalTo: flaggedButton.widthAnchor),
            flaggedButton.leadingAnchor.constraint(equalToSystemSpacingAfter: itemLabel.trailingAnchor, multiplier: 1),
            flaggedButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            flaggedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
        flaggedButton.addTarget(self, action: #selector(flaggedButtonTapped), for: .touchUpInside)
    }
    
    
    
    //MARK: - Button Functions
    private var completeButtonFunc: (() -> (Void))!
    private var flaggedButtonFunc: (() -> (Void))!
    
    @objc func completedButtonTapped() {
        completeButtonFunc()
    }
    
    @objc func flaggedButtonTapped() {
        flaggedButtonFunc()
    }
    
    /// Method called when the completed button is tapped.
    /// - Parameters:
    ///     - function: Takes an escaping function that is called when the completed button is tapped.
    @objc func toggleCompletedFunction(_ function: @escaping () -> Void) {
        self.completeButtonFunc = function
    }
    
    /// Method called whe the flagged button is tapped.
    /// - Parameters:
    ///     - function: Takes an escaping function that is called when the favorite button is tapped.
    @objc func toggleFlaggedFunction(_ function: @escaping () -> Void) {
        self.flaggedButtonFunc = function
    }
    
    
    //MARK: - Interface
    /// - Parameters:
       ///   - text: Item text to display in the TableView Cell.
       ///   - isFlagged: Boolean value if item is set as favorite.
       ///   - isComplete: Boolean value if the item is set to complete.
    func configureWidgetCellText(text: String, isFlagged: Bool, isComplete: Bool) {
        itemLabel.text = text
        self.flaggedButton.setImage(isFlagged ? SystemImages.StarFill! : SystemImages.Star!, for: .normal)
        self.flaggedButton.tintColor = isFlagged ? .systemYellow : Colors.tasksRed
        self.completedButton.setImage(isComplete ? SystemImages.CheckCircleFill! : SystemImages.CircleBlank!, for: .normal)
    }
    
    /// Sets the flagged status on the item. Method updates the view based on the status.
    /// - Parameters:
    ///    - isFavorite: The item's current favorite status.
    ///    - item: The item that is currently being updated.
    func widgetFlaggedTapped(isFavorite: Bool, item: Items) {
        self.flaggedButton.setImage(isFavorite ? SystemImages.Star! : SystemImages.StarFill!, for: .normal)
        self.flaggedButton.tintColor = isFavorite ?  Colors.tasksRed : .systemYellow
        item.isFlagged = !isFavorite
        item.lastUpdatedDate = Date()
        CoreDataManager().saveContext()
    }
    
    /// Sets the completed status on an Item. Once an item is marked as completed, the reminder date is set to nil and the item will be removed from this list. Updates the view based on the completed status.
    /// - Parameters:
    ///    - isComplete: The item's current completed status.
    ///    - item: The item that is currently being updated.
    func widgetCompleteTask(isComplete: Bool, item: Items) {
        self.completedButton.setImage(isComplete ? SystemImages.CircleBlank! : SystemImages.CheckCircleFill!, for: .normal)
        
        item.isComplete = !isComplete
        item.updateSectionIdentifier()
        item.reminderDate = nil
        item.lastUpdatedDate = Date()
        CoreDataManager().saveContext()
    }
}



