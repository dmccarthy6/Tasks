//
//  Calendar.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

typealias AddToCalendarResponse = (_ result: ResultCustomError) -> Void

final class CalendarManager: NSObject, CanWriteToDatabase {
    //MARK: - Properties
    weak var eventAddedDelegate: EventAddedDelegate?
    private var eventStore: EKEventStore
    
    
    
    //MARK: - Initializer
    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
        super.init()
    }
    
    
    
    //MARK: - User Authorization Methods
    private func requestAccessToCalendar(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    private func getCalendarAccessAuthStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    //Don't need these next two functions?
    private func addEvent(event: EKEvent, completion: @escaping AddToCalendarResponse) {
        if !eventAlreadyExists(event: event) {
            do {
                try eventStore.save(event, span: .thisEvent)
            }
            catch {
                completion(.failure(.eventNotAddedToCalendar))
            }
            completion(.success(true))
        }
        else {
            completion(.failure(.eventAlreadyExistsInCalendar))
        }
    }
    
    private func eventAlreadyExists(event eventToAdd: EKEvent) -> Bool {
        let eventExistsPredicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: eventExistsPredicate)
        
        let doesEventExist = existingEvents.contains { (event) -> Bool in
            return eventToAdd.title == event.title && eventToAdd.startDate == event.startDate && eventToAdd.endDate ==  event.endDate
        }
        return doesEventExist
    }
    
    //MARK: Presentation
    private func presentCalendarModalToAddEvent(event: EKEvent, completion: @escaping AddToCalendarResponse) {
        let authorizationStatus = getCalendarAccessAuthStatus()
        
        switch authorizationStatus {
        case .authorized:
            showAddToCalendarViewControllerModal(event: event)
            completion(.success(true))
            
        case .notDetermined:
            requestAccessToCalendar { (accessGranted, error) in
                if accessGranted {
                    self.showAddToCalendarViewControllerModal(event: event)
                    completion(.success(true))
                }
                else {
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
            
        case .denied, .restricted:
            completion(.failure(.calendarAccessDeniedOrRestricted))
            
        @unknown default: ()
        }
    }
    
    private func showAddToCalendarViewControllerModal(event: EKEvent) {
        let eventToUse = generateEvent(event: event)
        eventToUse.calendar = eventStore.defaultCalendarForNewEvents
        eventToUse.startDate = nil
        eventToUse.endDate = nil
        
        let addToCalendarViewController = EKEventEditViewController()
        addToCalendarViewController.editViewDelegate = self
        addToCalendarViewController.event = eventToUse
        addToCalendarViewController.eventStore = eventStore
        
        getKeyWindow().present(addToCalendarViewController, animated: true, completion: nil)
    }

    func generateEvent(event: EKEvent) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        
        let interval = TimeInterval(60)
        let eventAlarm = EKAlarm(relativeOffset: interval)
        
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = event.title
        newEvent.startDate = event.startDate
        newEvent.endDate = event.endDate
        newEvent.addAlarm(eventAlarm)
        return newEvent
    }
    
    //MARK: - Helper Methods
    private func getKeyWindow() -> UIViewController {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), let controller = window.visibleViewController() {
            return controller
        }
        return UIViewController()
    }
    
    //MARK: - Interface
    func addItemToCalendar(_ viewController: UIViewController, title: String, startDate: Date, endDate: Date, item: Items) {
        let event = generateEvent(event: EKEvent(eventStore: eventStore))//EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        
        presentCalendarModalToAddEvent(event: event) { (result) in
            switch result {
            case .success(let success):
                print("Success - Calendar: \(success)")
                
            case .failure(let error):
                switch error {
                case .calendarAccessDeniedOrRestricted:
                    Alerts.showSettingsAlert(viewController,
                                             message: CalendarAlertsMessage.restricted.rawValue)
                case .eventAlreadyExistsInCalendar:
                    Alerts.showNormalAlert(viewController,
                                           title: "",
                                           message: CalendarAlertsMessage.eventExists.rawValue)
                case .eventNotAddedToCalendar:
                    Alerts.showNormalAlert(viewController,
                                           title: "",
                                           message: CalendarAlertsMessage.eventNotAdded.rawValue)
                }
            }
        }
    }
    
}
//MARK: - EKEventEdit Delegate Methods
/*This is where we are saving the calendar information entered by the user (startDate/endDate etc.) */
extension CalendarManager: EKEventEditViewDelegate {
   
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
            
        case .canceled:
            print("CalendarManager - Event Was Cancelled")
            controller.dismiss(animated: true, completion: nil)
            
        case .saved:
            print("CalendarManager - Calendar Saved")
            if let event = controller.event {
                eventAddedDelegate?.eventAdded(event: event)
                controller.dismiss(animated: true, completion: nil)
            }
            
        case .deleted:
            print("CalendarManager - Calendar Event Deleted")
            
        @unknown default: ()
        }
    }
}


