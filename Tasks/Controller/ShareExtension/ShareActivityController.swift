//
//  ShareActivityController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

class ShareActivityController: UIActivityViewController {
    
    var items: [String]
    var activities: [UIActivity]?
    
    
    override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        self.items = activityItems as! [String]
        self.activities = applicationActivities
        
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    
    //, UIActivityItemSource
   func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
       return ["The pig is in the poke"]
   }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        if activityType == .mail {
            print("Mail")
            return items
        }
        if activityType == .airDrop {
            print("Air Drop")
            return items
        }
        if activityType == .message {
            print("MESSAGE DYLAN MESSAGE")
        }

        if activityType == .openTasks {
            print("OPEN TASKS")
            return items
        }
        return "Nil"
   }

//    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
//        return "Sharing List"
//    }
    
}//

