//
//  Enum_Errors.swift
//  Tasks
//
//  Created by Dylan  on 1/14/20.
//  Copyright © 2020 Dylan . All rights reserved.
//

import Foundation

enum Errors {
    
}

//MARK: - Calendar Errors
/*Custom result errors used in the CalendarManager */

enum ResultCustomError {
    case success(Bool)
    case failure(CustomError)
}

enum CustomError {
    case calendarAccessDeniedOrRestricted
    case eventNotAddedToCalendar
    case eventAlreadyExistsInCalendar
}
