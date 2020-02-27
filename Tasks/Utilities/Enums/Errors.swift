
//  Created by Dylan  on 1/14/20.
//  Copyright © 2020 Dylan . All rights reserved.

import Foundation

enum Errors {
    
}

/*
 *Error triggered if the user is not logged into iCloud. Using 'Alerts' alert to notify the user and let them make a decision via action buttons how to handle
 */
enum CloudKitErrorMessage: String {
    case noAccount
    case restricted
    case couldNotDetermine
    
    var message: String {
        switch self {
        case .noAccount:
            return "Log into iCloud to sync lists between devices. To log in click on settings below and log into your iCloud account on this device."
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
    case failure(CalendarError)
}

enum CalendarError: Error {
    case calendarAccessDeniedOrRestricted
    case eventNotAddedToCalendar
    case eventAlreadyExistsInCalendar
    case notDetermined
    
    var localizedDescription: String {
        switch self {
        case .calendarAccessDeniedOrRestricted:         return "Calendar access is restricted. Click settings to open the settings app and give Tasks access to your calendar."
        case .eventNotAddedToCalendar:                 return "Error - Event has not been added to your calendar."
        case .eventAlreadyExistsInCalendar:             return "Event already exists in your calendar."
        case .notDetermined:                        return "Not Determined"
        }
    }
}

