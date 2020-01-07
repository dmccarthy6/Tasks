//
//  Enums_Images.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

enum Images {
    static let AlarmClockIcon = UIImage(named: "AlarmClock")
    static let BellIcon = UIImage(named: "Bell")
    static let CalendarIcon = UIImage(named: "Calendar")
    static let CheckBoxBlankRedIcon = UIImage(named: "CheckBoxTasksRed")
    static let CompletedTasksIcon = UIImage(named: "CompletedIconTasks")
    static let EditIcon = UIImage(named: "Edit")
    static let EmptyFlagIcon = UIImage(named: "EmptyFlag")
    static let FlagFilledRedIcon = UIImage(named: "FlagTasksRed")
    static let ListIcon = UIImage(named: "ListIcon")
    static let MoreVerticalIcon = UIImage(named: "MoreVertical")
    static let PlusIcon = UIImage(named: "Plus")
    static let SaveIcon = UIImage(named: "SaveIcon")
    static let ShareIcon = UIImage(named: "Share")
    static let SyncIcon = UIImage(named: "Sync")
    
    //System Images -- iOS 13
    
}

enum FlagImage {
    static let EmptyFlag = UIImage(systemName: "flag")
    static let FilledFlag = UIImage(systemName: "flag.fill")
}

enum SystemImages {
    static let SystemShareIcon = UIImage(systemName: "square.and.arrow.up")
    static let CheckCircleFill = UIImage(systemName: "checkmark.circle.fill")
    static let CircleBlank = UIImage(systemName: "circle")
    static let CircleWithCheck = UIImage(systemName: "checkmark.circle.fill")
    static let Star = UIImage(systemName: "star")
    static let StarFill = UIImage(systemName: "star.fill")
    static let ListIcon = UIImage(systemName: "list.dash")
    static let AddListIcon = UIImage(systemName: "text.badge.plus")
    static let Plus = UIImage(systemName: "plus")
}

enum ListIcons: CaseIterable {
    
    static var count: Int { return allCases.count } 
    
    static let listDash = UIImage(systemName: "list.dash")
    static let linkCircle = UIImage(systemName: "link.circle")
    static let mapPinCircle = UIImage(systemName: "mappin.circle.fill")
    static let moonCircle = UIImage(systemName: "moon.circle.fill")
    static let airplane = UIImage(systemName: "airplane")
    static let carFill = UIImage(systemName: "car.fill")
    static let wifi = UIImage(systemName: "wifi")
    static let boltCircle = UIImage(systemName: "bolt.circle.fill")
    static let cartFill = UIImage(systemName: "cart.fill")
    static let bandageFill = UIImage(systemName: "bandage.fill")
    static let personCircle = UIImage(systemName: "person.crop.circle.fill")
    static let phoneCircle = UIImage(systemName: "phone.circle.fill")
    static let envelopeCircle = UIImage(systemName: "envelope.circle.fill")
}
