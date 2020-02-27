//
//  Date.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation

extension Date {
    
    func dateOnlyToString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MMM dd, yyyy h:mm a" //"MMM d, y"//"yyyy/MM/dd hh:ss" m/dd/yy, h:m//BEFORE I CHANGED IT "MMM/dd/yyyy h:mm a"
        let stringDate = dateFormatter.string(from: date)
        return stringDate
    }
    
    
    func getReminderDateAsString(pickerDate: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yy h:m a"
        let dateString = dateFormatter.string(from: pickerDate)
        return dateString
    }
    
    func setInitialCalendarEndDate() -> Date? {
        let minutesToAdd = 30
        
        var dateComponent = DateComponents()
        dateComponent.minute = minutesToAdd
        
        if let endDate = Calendar.current.date(byAdding: dateComponent, to: self) {
            return endDate
        }
        return nil
    }
}
