
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
    weak var eventAddedDelegate: EventAddedDelegate?
    private var eventStore: EKEventStore
    
    
    
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
                    completion(.success(eventController))
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
            event.endDate = endDate
            event.calendar = eventStore.defaultCalendarForNewEvents
        
        let eventModalVC = EKEventEditViewController()
         if !eventAlreadyExists(eventToAdd: event) {
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
//        eventModalVC.editViewDelegate = self
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

    //MARK: - EKEventEdit Delegate Methods
    /*
        * EKEventKit Delegate methods. This delegate triggers when user hits cancel or add in the Nav Controller.
    */
extension CalendarManager: EKEventEditViewDelegate, UINavigationControllerDelegate { //, UINavigationControllerDelegate
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        print("CALENDAR DELEGATE HIT")
        switch action {
        case .canceled:
            controller.dismiss(animated: true, completion: nil)

        case .saved:
            if let event = controller.event {
                eventAddedDelegate?.eventAdded(event: event)
                controller.dismiss(animated: true, completion: nil)
            }

        case .deleted:
            print("CalendarManager - Calendar Event Deleted")
            controller.dismiss(animated: true, completion: nil)

        @unknown default: ()
        }
    }
    
}


//protocol CalendrMGR {
//
//    var calendarDelegate: EKEventEditViewDelegate { get set }
//    var viewController: UIViewController { get }
//}
//
//extension CalendrMGR {
//
//    var eventStore: EKEventStore {
//        return EKEventStore()
//    }
//
//    func presentModalCalendarController(title: String, startDate: Date, endDate: Date, completion: @escaping (Result<EKEventEditViewController, CalendarError>) -> Void) {
//        let eventController = createEventModalController(title: title, startDate: startDate, endDate: endDate)
//        switch EKEventStore.authorizationStatus(for: .event) {
//        case .authorized:
//            print("CalendarManager - AUTH to add events")
//            completion(.success(eventController))
//        case .denied, .restricted:
//            print("CalendarManage - Denied")
//            completion(.failure(.calendarAccessDeniedOrRestricted))
//        case .notDetermined:
//            eventStore.requestAccess(to: .event) { (granted, error) in
//                if granted {
//                    completion(.success(eventController))
//                }
//                else {
//                    completion(.failure(.calendarAccessDeniedOrRestricted))
//                }
//            }
//        @unknown default: ()
//        }
//    }
//
//    func showEventEditController(for title: String, startDate: Date, endDate: Date) {
//        switch EKEventStore.authorizationStatus(for: .event) {
//        case .authorized:
//            print("CalendarManager Protocol - Authorized to access Calendar")
//            viewController
//
//        case .denied, .restricted:
//            print("CalendarManager Protocol - Denied or Restricted")
//            //Throw Error?
//
//        case .notDetermined:
//            eventStore.requestAccess(to: .event) { (granted, error) in
//                if granted {
//                    //SHOW VC
//                }
//                else {
//                    //ERROR
//                }
//            }
//        }
//    }
//
//    private func showViewController(title: String, startDate: Date, endDate: Date) {
//        let event = EKEvent(eventStore: eventStore)
//
//        event.title = title
//        event.startDate = startDate
//        event.endDate = endDate
//        event.calendar = eventStore.defaultCalendarForNewEvents
//
//        let eventModalVC = EKEventEditViewController()
//        if !eventAlreadyExists(eventToAdd: event) {
//            eventModalVC.event = event
//            eventModalVC.eventStore = eventStore
//            eventModalVC.delegate = viewController
//        }
//    }
//
//    private func createEventModalController(title: String, startDate: Date, endDate: Date) -> EKEventEditViewController {
//        let event = EKEvent(eventStore: eventStore)
//
//            event.title = title
//            event.startDate = startDate
//            event.endDate = endDate
//            event.calendar = eventStore.defaultCalendarForNewEvents
//
//        let eventModalVC = EKEventEditViewController()
//         if !eventAlreadyExists(eventToAdd: event) {
//        eventModalVC.event = event
//        eventModalVC.eventStore = eventStore
//        }
//        return eventModalVC
//    }
//
//    private func eventAlreadyExists(eventToAdd: EKEvent) -> Bool {
//        let predicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: nil)
//        let existingEvents = eventStore.events(matching: predicate)
//
//        let eventExists = existingEvents.contains { (event) -> Bool in
//            return event.title == eventToAdd.title && event.startDate == eventToAdd.startDate && eventToAdd.endDate == event.endDate
//        }
//        return eventExists
//    }
//}
//
//extension EditItemViewController {
//
//}
