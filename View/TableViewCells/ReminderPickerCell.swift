//
//  ReminderPickerCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

protocol DatePickerChangedDelegate: class {
    func didChangeDateOnDatePicker(date: Date, indexPath: IndexPath)
}

final class ReminderDatePickerCell: UITableViewCell, CanWriteToDatabase {
    
    //MARK: - Properties
    var alertDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.minimumDate = Date()
        datePicker.backgroundColor = .systemBackground
        return datePicker
    }()
    private var datePickerHeight: CGFloat = 200
    
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //MARK: - Helpers
    private func setupView() {
        contentView.addSubview(alertDatePicker)
        
        let guide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            alertDatePicker.topAnchor.constraint(equalTo: guide.topAnchor),
            alertDatePicker.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            alertDatePicker.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            alertDatePicker.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
        ])
        
        backgroundColor = .systemBackground
    }
    

    //MARK: - Interface
    func toggleDatePicker() {
        alertDatePicker.isHidden = !alertDatePicker.isHidden
    }
    
}
