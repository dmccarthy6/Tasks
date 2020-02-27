//
//  TasksActivity.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

class TasksActivity: UIActivity {
    
    //MARK: - Properties
    var _activityTitle: String
    var _activityImage: UIImage?
    var activityItems = [Any]()
    var action: ([Any]) -> Void
    
    
    init(title: String, image: UIImage?, performAction: @escaping ([Any]) -> Void) {
        _activityTitle = title
        _activityImage = image
        action = performAction
        
        super.init()
    }
    
    //MARK: - Override class properties
    override var activityTitle: String? {
        return _activityTitle
    }
    
    override var activityImage: UIImage? {
        return _activityImage
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: "com.mccarthy.Tasks.tasksopen")
    }
    
    override class var activityCategory: UIActivity.Category {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems
    }
    
    override func perform() {
        action(activityItems)
        activityDidFinish(true)
    }
    
    
    
}

extension UIActivity.ActivityType {
    
    static let openTasks = UIActivity.ActivityType("com.mccarthy.Tasks.tasksopen")
}
