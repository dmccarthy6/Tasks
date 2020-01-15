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

/* Messages showng if CloudKit Not Enabled*/
enum CloudKitErrorMessage: String {
    case noAccount
    case restricted
    case couldNotDetermine
    
    var message: String {
        switch self {
        case .noAccount:
            return "You are not logged into iCloud. Click settings to enable iCloud for Tasks in order to keep all your devices updated."
        case .restricted:
            return "iCloud account is restricted for this content. Click on settings below to update your iCloud settings."
        case .couldNotDetermine:
            return "Unable to determine iCloud status. Click settings to log into iCloud"
        }
    }
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
