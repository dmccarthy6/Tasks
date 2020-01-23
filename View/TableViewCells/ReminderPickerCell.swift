//
//  ReminderPickerCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit


final class ReminderDatePickerCell: UITableViewCell, CanWriteToDatabase {
    
    //MARK: - Properties
    var alertDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Interface
    func setPickerConstraints() {
        contentView.addSubview(alertDatePicker)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            alertDatePicker.topAnchor.constraint(equalTo: guide.topAnchor),
            alertDatePicker.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
        ])
        
        backgroundColor = .systemBackground
    }
    
}
