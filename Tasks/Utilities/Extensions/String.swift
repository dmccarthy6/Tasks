//
//  String.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation

extension String {
    
    func checkIf(reminderDate date: String, isLessThan today: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-dd"
        
        guard let date = dateFormatter.date(from: date) else {
            return false
        }
        
        if date < today {
            return true
        }
        else {
            return false
        }
    }
    
    func setDatePickerDateTo(currentReminderDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd, yyyy h:mm a"
        
        let date = dateFormatter.date(from: currentReminderDate)
        return date!
    }
}
