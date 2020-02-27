//
//  OpenTasks.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import CoreData
import UIKit
import TasksFramework

struct OpenTasks {
    
    //static var listDataDelegate: GetCurrentListDataDelegate!
    static var itemList: NSManagedObject!
    static var id: String!
   
    
    static func openTasksApp(context: NSExtensionContext) {
        let url: NSURL = NSURL(string: "tasksopen://")!
        context.open(url as URL) { (success) in
            if success {
                print("Success!!!")
                //TO-DO: Get List Title ID, Pass to VC Open Correct V.C.
            }
            else {
                print("FAILURE TO OPEN APP FROM EXTENSION -- OpenTasksStruct")
            }
        }
    }
    
    static func openListItems(in context: NSExtensionContext, item: Items) {
        let itemsControllerURL: NSURL = NSURL(string: "tasksopen://addItemsVC")!
        let groupUserDefaults = UserDefaults(suiteName: "group.Tasks.Extensions")
        
        context.open(itemsControllerURL as  URL) { (success) in
            if !success {
                return
            }
            else {
                let listTitleID = item.titleID
                
                
                do {
                    let listTitleIDEncoded = try NSKeyedArchiver.archivedData(withRootObject: listTitleID ?? "", requiringSecureCoding: false)
//                    groupUserDefaults?.setValue(listEncoded, forKey: "tappedList")
                    groupUserDefaults?.setValue(listTitleIDEncoded, forKey: "tappedID")
                }
                catch let error as NSError {
                    print(error)
                    return
                }
            }
        }
    }
}

enum MyURL {
    
}
