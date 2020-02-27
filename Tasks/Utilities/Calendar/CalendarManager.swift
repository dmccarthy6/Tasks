
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
    
    private func eventAlreadyExists(eventToAdd: EKEvent) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        
        let eventExists = existingEvents.contains { (event) -> Bool in
            return event.title == eventToAdd.title && event.startDate == eventToAdd.startDate && eventToAdd.endDate == event.endDate
        }
        return eventExists
    }

}
