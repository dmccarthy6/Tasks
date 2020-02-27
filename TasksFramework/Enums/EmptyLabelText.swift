//
//  EmptyLabelText.swift
//  TasksFramework
//
//  Created by Dylan  on 2/12/20.
//  Copyright © 2020 Dylan . All rights reserved.
//


enum EmptyDataText {
    case noRemindersSetToday
    
    var message: String {
        switch self {
        case .noRemindersSetToday:  return "No Tasks Due Today"
        }
    }
}
