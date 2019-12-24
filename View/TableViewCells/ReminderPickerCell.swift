//
//  ReminderPickerCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

class ReminderDatePickerCell: UITableViewCell {
    
    var alertDatePicker: UIDatePicker = {
        let alertDatePicker = UIDatePicker()
        alertDatePicker.isHidden = true
        alertDatePicker.minimumDate = Date()
        if #available(iOS 13.0, *) { alertDatePicker.backgroundColor = .systemBackground }
        return alertDatePicker
    }()
    var datePickerHeight: CGFloat = 200
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addDatePickersToCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addDatePickersToCell() {
        addSubview(alertDatePicker)
        
        alertDatePicker.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 5, left: 5, bottom: 5, right: 5), size: .init(width: frame.size.width, height: datePickerHeight))
    }
}//
