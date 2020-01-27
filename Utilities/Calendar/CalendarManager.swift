
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

typealias EventsCalendarManagerResponse = (_ result: ResultCustomError) -> Void

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
        
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        return eventModalVC
    }
}
//MARK: - EKEventEdit Delegate Methods
/*This is where we are saving the calendar information entered by the user (startDate/endDate etc.) */
extension CalendarManager: EKEventEditViewDelegate, UINavigationControllerDelegate {
   
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
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


