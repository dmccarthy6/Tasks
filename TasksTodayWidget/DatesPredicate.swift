//
//  DatesPredicate.swift
//  TasksTodayWidget
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

enum DatesPredicate {
    
    static func getCalendar() -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        return calendar
    }
    
    static func reminderDateIsTodayPredicate() -> NSPredicate {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let todayDate = Date()
        let dayBeginning = calendar.startOfDay(for: todayDate)
        let dayEnding = calendar.date(byAdding: .day, value: 1, to: dayBeginning)!
        
        let dayBeginningString = convertDateToString(date: dayBeginning)
        let dayEndString = convertDateToString(date: dayEnding)
        
        return NSPredicate(format: "reminderDate >= %@ AND reminderDate <= %@", dayBeginningString, dayEndString)
    }
    
    private static func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy h:m a"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    private static func beginningDate() -> String {
        let calendar = getCalendar()
        let todayDate = Date()
        let dayBeginning = calendar.startOfDay(for: todayDate)
        let dayBeginningString = convertDateToString(date: dayBeginning)
        return dayBeginningString
    }
    
    private static func endingDate() -> String {
        let calendar = getCalendar()
        let todayDate = Date()
        let dayBeginning = calendar.startOfDay(for: todayDate)
        let dayEnding = calendar.date(byAdding: .day, value: 1, to: dayBeginning)
        let dayEndingString = convertDateToString(date: dayEnding!)
        return dayEndingString
    }
    
    
}

