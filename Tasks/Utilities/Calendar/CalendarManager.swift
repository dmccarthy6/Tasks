
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

typealias EventsCalendarManagerResponse = (_ result: ResultCustomError) -> Void

/*
 CalendarManager handles the EKEventKit methods, this class is used when users tap "Due Date" on the MenuCell to add tasks to their calendar.
 */

final class CalendarManager: NSObject, CanWriteToDatabase {
    //MARK: - Properties
    private var eventStore: EKEventStore
    private var tempTitle: String?
    private var tempStartDate: Date?
    private var tempEndDate: Date?
    
    
    
    //MARK: - Initializer
    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
        super.init()
    }
    
    
    //MARK: - Add event to calendar
    
    ///Checks authorization status for EKEventStore if authorized passes the EKEventEditViewController to the completion handler. If the status is notDetermined 'requestAccess' is called
    ///
    /// - Parameters:
    ///     - title: Item Name that will be set as the calendar event title.
    ///     - startDate: Start date initially set to the current date/time
    ///     - endDate: End date initially set to 30 minutes after current date/time
    ///     - completion: escaping closure
    func presentModalCalendarController(title: String, startDate: Date, endDate: Date, completion: @escaping (Result<EKEventEditViewController, CalendarError>) -> Void) {
        let eventController = createEventModalController(title: title, startDate: startDate, endDate: endDate)
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            print("CalendarManager - AUTH to add events")
            completion(.success(eventController))
        case .denied, .restricted:
            print("CalendarManage - Denied")
            completion(.failure(.calendarAccessDeniedOrRestricted))
        case .notDetermined:
            eventStore.requestAccess(to: .event) { (granted, error) in
                if granted {
                    
                }
                else {
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
        @unknown default: ()
        }
    }
    
    ///Creates the add event to calendar View Controller using the parameters passed in to set the title, startDate and endDate values on the modal screen. User can change
    ///these values if they desire in the view controller before saving.
    /// - Parameters:
    ///     - title: Item title which will be used to create the EKEvent Title.
    ///     - startDate: Event start date
    ///     - endDate: Event end date
    /// - Returns: EKEventEditViewController
    private func createEventModalController(title: String, startDate: Date, endDate: Date) -> EKEventEditViewController {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate.setInitialCalendarEndDate()
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let eventModalVC = EKEventEditViewController()
        if !eventAlreadyExists(eventToAdd: event) {
            eventModalVC.event = event
            eventModalVC.eventStore = eventStore
        }
        return eventModalVC
    }
    
    
    ///Checking if the event we are trying to add already exists in the user's calendar.
    /// - Parameters:
    ///     - eventToAdd: EKEvent value
    /// - Returns: Boolean value returns True if event exists and False if it does not.
    private func eventAlreadyExists(eventToAdd: EKEvent) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        
        let eventExists = existingEvents.contains { (event) -> Bool in
            return event.title == eventToAdd.title && event.startDate == eventToAdd.startDate && eventToAdd.endDate == event.endDate
        }
        return eventExists
    }

}
