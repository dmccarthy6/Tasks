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

protocol EventAddedDelegate {
    func eventAdded(event: EKEvent)
}

typealias AddToCalendarManagerResponse = (_ result: ResultCustomError) -> Void

class AddToCalendar: NSObject {
    
    static let shared = AddToCalendar()
    var eventStore: EKEventStore!
    var savedEvent: EKEvent?
    var eventAddedDelegate: EventAddedDelegate!
    
    
    override init() {
        super.init()
        eventStore = EKEventStore()
    }
    
    //Requesting Access To Calendar:
    private func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    //Get Calendar Authorization Status
    private func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    //Check Calendar Permissions Auth Status
    //Try to add event if authorized
    func addEventToCalendar(event: EKEvent, completion: @escaping AddToCalendarManagerResponse) {
        let authStatus = getAuthorizationStatus()
        
        switch authStatus {
        case .authorized:
            //Authorized, we are good
            self.addEvent(event: event) { (success) in
                switch success {
                case .success:
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        case .notDetermined:
            //Auth is not determined
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    self.addEvent(event: event, completion: { (result) in
                        switch result {
                        case .success:
                            completion(.success(true))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                }
                else {
                    //Alert - Access denied, Alert User
                    //Alerts.shared.showAlert(<#T##viewController: UIViewController##UIViewController#>, message: <#T##String#>, okAction: <#T##(() -> ())?##(() -> ())?##() -> ()#>)
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
        case .denied, .restricted:
            //Authorization denied OR restricted, alert User
            //Alerts.shared.showAlert(<#T##viewController: UIViewController##UIViewController#>, message: <#T##String#>, okAction: <#T##(() -> ())?##(() -> ())?##() -> ()#>)
            completion(.failure(.calendarAccessDeniedOrRestricted))
            print("Not Sure Why This Won't Work - Error Denied/Restricted")
        }
    }
    
    //
    private func generateEvent(event: EKEvent) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = event.title
        newEvent.startDate = event.startDate
        newEvent.endDate = event.endDate
        
        let timeInterval = TimeInterval(60)
        let alarm = EKAlarm(relativeOffset: timeInterval)
        newEvent.addAlarm(alarm)
        return newEvent
    }
    
    
    //Try To Save To Calendar
    private func addEvent(event: EKEvent, completion: @escaping AddToCalendarManagerResponse) {
        let eventToAdd = generateEvent(event: event)
        
        if !eventAlreadyExists(event: eventToAdd) {
            do {
                try eventStore.save(eventToAdd, span: .thisEvent)
            }catch {
                completion(.failure(.eventNotAddedToCalendar))
            }
            completion(.success(true))
        }
        else {
            completion(.failure(.eventAlreadyExistsInCalendar))//ERROR SHOLD BE EVENT ALREADY EXISTS
        }
    }
    
    private func eventAlreadyExists(event eventToAdd: EKEvent) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        
        let eventAlreadyExists = existingEvents.contains { (event) -> Bool in
            return eventToAdd.title == event.title && event.startDate == eventToAdd.startDate && event.endDate == eventToAdd.endDate
        }
        return eventAlreadyExists
    }
    
    func presentCalendarModalToAddEvent(event: EKEvent, completion: @escaping AddToCalendarManagerResponse) {
        let authStatus = getAuthorizationStatus()
        
        switch authStatus {
        case .authorized:
            print("Calendar = Success")
            presentEventCalendarDetailModal(event: event)
            completion(.success(true))
        case .notDetermined:
            //Not Authorized, Request Access to Calendar
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    self.presentEventCalendarDetailModal(event: event)
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
    
    func presentEventCalendarDetailModal(event: EKEvent) {
        let event = generateEvent(event: event)
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.startDate = nil
        event.endDate = nil
        
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        eventModalVC.editViewDelegate = self
        
        if let window = UIApplication.shared.windows.first(where:{ $0.isKeyWindow }), let controller = window.visibleViewController() {
            controller.present(eventModalVC, animated: true, completion: nil)
        }
    }
    
    func passEventData(completion: @escaping (_ event: EKEvent) -> Void) {
//        guard let savedEvent = savedEvent else { return }
//        completion(savedEvent)
    }
    
}//
extension AddToCalendar: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        
        switch action {
        case .canceled:
            print("Event Cancelled")
            controller.dismiss(animated: true, completion: nil)
        case .saved:
            print("Event Saved")
            guard let event = controller.event else { return }
            eventAddedDelegate.eventAdded(event: event)
            
            
            controller.dismiss(animated: true, completion: nil)
        case .deleted:
            print("Event Deleted")
            
        @unknown default: ()
        }
//        controller.dismiss(animated: true, completion: nil)
//        let menuLauncher = MenuLauncher()
//        menuLauncher.showReminderMenu()
    }
}

enum ResultCustomError {
    case success(Bool)
    case failure(CustomError)
}

enum CustomError {
    case calendarAccessDeniedOrRestricted
    case eventNotAddedToCalendar
    case eventAlreadyExistsInCalendar
}
