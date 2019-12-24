//
//  Notifications.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class Notifications: NSObject {
    
    public static let shared = Notifications()
    
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Access Granted")
            }
            else {
                print("No Notification Access")
            }
        }
    }
    
    static func checkNotificationCenterAuthorizationStatus(for viewController: UIViewController) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                print("Notifications Are Authorized! (Notifications.swift)")
                break
            case .denied:
                print("Notifications Denied - (Notifications.swift)")
                Alerts.showSettingsAlert(viewController, message: "Notifications are Disabled. Click Settings, Notifications, then click on Tasks and select Allow Notifications in order to receive notifications from this app.")
            case .notDetermined:
                print("Notification Center Not Determined - Not Set Up? (Notifications.swift)")
                Alerts.showSettingsAlert(viewController, message: "Notifications are Disabled. Click Settings, Notifications, then click on the Tasks icon and select Allow Notifications")
            case .provisional:
                print("Provisiional")
            @unknown default:
                Alerts.showSettingsAlert(viewController, message: "Unknwon Error")
            }
        }
    }
    
    func createNotification(from date: Date, item: Items) {
        requestAuthorization()
        
        let center = UNUserNotificationCenter.current()
        //Calendar
        let calendar = Calendar(identifier: .gregorian)
        let calendarComponents = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, era: nil, year: nil, month: calendarComponents.month, day: calendarComponents.day, hour: calendarComponents.hour, minute: calendarComponents.minute, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        
        //Content
        guard let safeItem = item.item, let safeTitle = item.list?.title else {
            return
        }
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "Task"
        content.title = safeTitle
        content.body =  safeItem
        content.sound = UNNotificationSound.default
        
        //Trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "Task", content: content, trigger: trigger)
        
        //Set Alert
        center.removeAllPendingNotificationRequests()
        center.add(request) { (error) in
            if let error = error {
                print("Error Adding Alert \(error.localizedDescription)")
            }
        }
        registerCategories()
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let openTasks = UNNotificationAction(identifier: "Open", title: "View Task", options: .foreground)
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let categories = UNNotificationCategory(identifier: "Task", actions: [openTasks, snoozeAction], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([categories])
    }
    
    func snoozeTask(response: UNNotificationResponse) {//CURRENTLY 5 MIN SNOOZE
        let center = UNUserNotificationCenter.current()
        let snoozeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 300.0, repeats: false)
        let snoozeRequest = UNNotificationRequest(identifier: "Task", content: response.notification.request.content, trigger: snoozeTrigger)
        center.add(snoozeRequest) { (error) in
            if error != nil {
                print("Error Snoozing \(error?.localizedDescription)")
            }
        }
    }
    
}//

extension Notifications: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            //User Swiped to unlock phone
            print("Default Identifier")
        case "Open":
            print("Open the App")
            break
        case "Snooze":
            snoozeTask(response: response)
            break
        default:
            break
        }
        completionHandler()
    }
    
}

