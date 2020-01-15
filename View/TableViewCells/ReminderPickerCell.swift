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
        
        alertDatePicker.anchor(top: safeAreaLayoutGuide.topAnchor,
                               leading: safeAreaLayoutGuide.leadingAnchor,
                               bottom: safeAreaLayoutGuide.bottomAnchor,
                               trailing: safeAreaLayoutGuide.trailingAnchor,
                               padding: .init(top: 0, left: 5, bottom: 5, right: 5),
                               size: .init(width: frame.size.width, height: datePickerHeight))
        alertDatePicker.isHidden = true
    }
    

    //MARK: - Interface
    func toggleDatePicker() {
        alertDatePicker.isHidden = !alertDatePicker.isHidden
    }
    
}
