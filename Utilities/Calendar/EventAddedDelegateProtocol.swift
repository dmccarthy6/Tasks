//
//  AddCalendarEvent.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import EventKit


protocol EventAddedDelegate: class {
    
    func eventAdded(event: EKEvent)
    
}

extension EventAddedDelegate {
    //MARK: - Extension Methods
    
    func eventAdded(event: EKEvent) {
        let eventDate = event.startDate
    }
}

//struct AddCalendarEvent {
    
//    let viewController: UIViewController
//    let title: String
//    let startDate: Date
//    let endDate: Date
//    let item: Items
//
//    private let calendarManager = AddToCalendar()
//
//
//    init(viewController: UIViewController, title: String, startDate: Date, endDate: Date, item: Items) {
//        self.viewController = viewController
//        self.title = title
//        self.startDate = startDate
//        self.endDate = endDate
//        self.item = item
//
//        addListItemToCalendar()
//        calendarManager.eventAddedDelegate = self
//    }
//
//    private func createEvent(calendarManager: AddToCalendar, title: String) -> EKEvent {
//        let event = EKEvent(eventStore: calendarManager.eventStore)
//        event.title = title
//        return event
//    }
//
//    func addListItemToCalendar() {
//        let calendarEvent = createEvent(calendarManager: calendarManager, title: title)
//
//        calendarManager.presentCalendarModalToAddEvent(event: calendarEvent) { (result) in
//            switch result {
//
//            case .success(let success):
//                print("Successfully Added: \(success)")
//
//            case .failure(let error):
//                switch error {
//                case .calendarAccessDeniedOrRestricted:
//                    Alert.showSettingsBasicAlert(self.viewController,
//                                                 title: "Calendar Access Denied",
//                                                 message: CalendarAlertsMessage.restricted.rawValue)
//
//                case .eventAlreadyExistsInCalendar:
//                    Alerts.showNormalAlert(self.viewController,
//                                           title: "",
//                                           message: CalendarAlertsMessage.eventExists.rawValue)
//
//                case .eventNotAddedToCalendar:
//                    Alerts.showNormalAlert(self.viewController,
//                                           title: "",
//                                           message: CalendarAlertsMessage.eventNotAdded.rawValue)
//                }
//            }
//        }
//    }
//}

//extension AddCalendarEvent: EventAddedDelegate {
//    func eventAdded(event: EKEvent) {
//        func eventAdded(event: EKEvent) {
//            let eventDate = event.startDate
//            CoreDataManager.shared.setDueDate(item: item, date: eventDate!)
//        }
//    }
    
    
//}
