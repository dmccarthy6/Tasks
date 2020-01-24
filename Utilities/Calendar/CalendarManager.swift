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
    var userEvent: EKEvent?
    
    
    //MARK: - Initializer
    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
        super.init()
    }
    
    
    
    //MARK: - User Authorization Methods
    func requestAccessToCalendar(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    private func getCalendarAccessAuthStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
//    //MARK: Presentation
//    private func presentCalendarModalToAddEvent(event: EKEvent, completion: @escaping AddToCalendarResponse) {
//        let authorizationStatus = getCalendarAccessAuthStatus()
//
//        switch authorizationStatus {
//        case .authorized:
//            showAddToCalendarViewControllerModal(event: event)
//            completion(.success(true))
//
//        case .notDetermined:
//            requestAccessToCalendar { (accessGranted, error) in
//                if accessGranted {
//                    self.showAddToCalendarViewControllerModal(event: event)
//                    completion(.success(true))
//                }
//                else {
//                    completion(.failure(.calendarAccessDeniedOrRestricted))
//                }
//            }
//
//        case .denied, .restricted:
//            completion(.failure(.calendarAccessDeniedOrRestricted))
//
//        @unknown default: ()
//        }
//    }
    
    private func generateEvent(event: EKEvent) -> EKEvent {
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
    
    func addToDoItemToCalendar(title: String, eventStartDate: Date, eventEndDate: Date, completion: @escaping AddToCalendarResponse) {
        //Create EKEvent with data passed in from user.
        let event = generateEvent(event: EKEvent(eventStore: eventStore))
        event.title = title
        event.startDate = eventStartDate
        event.endDate = eventEndDate
        
        //Check Authorization Status and pass to completion based on status.
        let status = getCalendarAccessAuthStatus()
        
        switch status {
        case .authorized:
            print("Auth Do Somethig")
            self.userEvent = event
            completion(.success(true))
            print("Success")
            
        case .denied, .restricted:
            completion(.failure(.calendarAccessDeniedOrRestricted))
            print("Denied do something")
            
        case .notDetermined:
            completion(.failure(.notDetermined))
            print("Not Determined")
        @unknown default: ()
        }
    }
    
    func addViewController() -> EKEventEditViewController {
        let addToCalendarViewController = EKEventEditViewController()
        addToCalendarViewController.editViewDelegate = self
        addToCalendarViewController.event = userEvent!
        addToCalendarViewController.eventStore = self.eventStore
        return addToCalendarViewController
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


