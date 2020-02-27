//
//  DateExtension.swift
//  TasksFramework
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation

extension Date {
    
    fileprivate func getDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yy h:m a"
        return dateFormatter
    }
    
    func dateOnlyToString(date: Date) -> String {
        let dateFormatter = getDateFormatter()
        let stringDate = dateFormatter.string(from: date)
        return stringDate
    }
    

    
}
