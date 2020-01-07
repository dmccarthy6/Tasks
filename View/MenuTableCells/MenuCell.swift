//
//  MenuCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import EventKit

class MenuCell: UITableViewCell {
    
    let cellHeight: CGFloat = 50

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = DynamicFonts.Title1Dynamic
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.font = DynamicFonts.Title2Dynamic
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createMenuCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createMenuCell() {
        selectionStyle = .none
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        setConstraints()
    }
    //width: iconImageView.image?.size.width ?? 0.0, height: iconImageView.image?.size.height ?? 0.0))
    func setConstraints() {
        iconImageView.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: titleLabel.leadingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: iconImageView.image?.size.width ?? 50, height: iconImageView.image?.size.height ?? 50))
        titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, leading: iconImageView.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: valueLabel.leadingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: frame.size.width/2, height: cellHeight))
        //if valueLabel.text != "" {
            
            valueLabel.anchor(top: safeAreaLayoutGuide.topAnchor, leading: titleLabel.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 10), size: .init(width: frame.size.width/2, height: cellHeight))
        //}
    }
    
    func eventAdded(event: EKEvent) {
        guard let startDate = event.startDate else { return }
        let endDate = event.endDate
        
        let stringStartDate = startDate.dateOnlyToString(date: startDate)
        valueLabel.text = stringStartDate
    }
    
    func setMenuCellColors() {
        backgroundColor = Colors.tasksRed
        titleLabel.backgroundColor = Colors.tasksRed
        titleLabel.textColor = .label
        valueLabel.backgroundColor = Colors.tasksRed
        valueLabel.textColor = .label
        iconImageView.backgroundColor = Colors.tasksRed
    }
    
    func configure(image: UIImage, tintColor: UIColor?, text: String) {
        self.imageView?.image = image
        //self.imageView?.backgroundColor = .systemPink
        //self.imageView?.tintColor = tintColor
        self.textLabel?.text = text
    }
    
    func configureValue(value: String) {
        self.valueLabel.text = value
        handlePastDueDate(reminder: value)
    }
    
    private func handlePastDueDate(reminder: String) {
        let todaysDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd/yy h:m a"
        
        if let reminderDate = formatter.date(from: reminder) {
            if reminderDate < todaysDate {
                valueLabel.textColor = Colors.tasksRed
                valueLabel.font = DynamicFonts.Title2Dynamic
            }
        }
    }
}
