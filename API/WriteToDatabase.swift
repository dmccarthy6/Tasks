//
//  WriteToDatabase.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import CoreData


@objc protocol CanWriteToDatabase: NSObjectProtocol {

}

extension CanWriteToDatabase {
    
    var managedObjectContext: NSManagedObjectContext {
        get {
            return CoreDataManager.shared.mainThreadManagedObjectContext
        }
    }
    
    func delete<T: NSManagedObject>(_ object: T){
        
    }
    
    //MARK: - Save Objects
    func saveObjectToCoreData<T: NSManagedObject>(value: String, order: Int, entity: Entity, parent: T?) {
        if entity == .List {
            print("THIS IS A LIST")
            let addedListTitle = NSEntityDescription.insertNewObject(forEntityName: entity.rawValue, into: managedObjectContext) as! List
            
            //UUID
            let titleUUID = UUID().uuidString
            let titleID = titleUUID.data(using: .utf8) as Data?
            
            addedListTitle.title = value
            addedListTitle.order = Int32(order)
            addedListTitle.recordID = titleID
            addedListTitle.dateAdded = Date()
            addedListTitle.lastUpdateDate = Date()
            addedListTitle.isCompleted = false
            print("List Saved")
            saveContext()
        }
        
        if entity == .Items {
            print("YOU HAVE AN ITEM")
            let addedItem = NSEntityDescription.insertNewObject(forEntityName: entity.rawValue, into: managedObjectContext) as! Items
            
            let itemUUIDString = UUID().uuidString
            let itemID = itemUUIDString.data(using: .utf8) as Data?
            
            let list = parent as! List
            let items = [list.items]
            let itemOrder: Int32 = Int32(order + 1)
            
            addedItem.list = parent as! List
            addedItem.item = value
            addedItem.order = itemOrder
            addedItem.titleID = String(data: list.recordID!, encoding: .utf8)
            addedItem.recordID = itemID
            addedItem.dateAdded = Date()
            addedItem.lastUpdatedDate = Date()
            addedItem.isComplete = false
            addedItem.isFlagged = false
            addedItem.updateSectionIdentifier()
            saveContext()
        }
    }
    
    func setAlertOnItem(item: Items, alertDate: Date) {
        item.reminderDate = alertDate.dateOnlyToString(date: alertDate)
        item.lastUpdatedDate = Date()
        saveContext()
        Notifications.shared.createNotification(from: alertDate, item: item)
    }
    
    func setDueDateForItem(item: Items, date: Date) {
        item.dueDate = date.dateOnlyToString(date: date)
        item.lastUpdatedDate = Date()
        saveContext()
    }
    
    //MARK - Set Completed Status && Flagged Status
    func setItemCompletedStatus(item: Items) {
        let itemCurrentStatus = item.isComplete
        item.isComplete = !itemCurrentStatus
        item.reminderDate = "" //Setting Reminder to nil -- it's complete
        item.updateSectionIdentifier()
        item.lastUpdatedDate = Date()
        saveContext()
    }
    
    func setItemAsFlagged(item: Items, status: Bool) {
        item.isFlagged = status
        item.lastUpdatedDate = Date()
        saveContext()
    }
    
    //MARK: - Update Objects
    func updateObject<T: NSManagedObject>(object: T, value: String, entity: Entity) {
        if entity == .List {
            let list = object as! List
            list.title = value
            list.lastUpdateDate = Date()
            saveContext()
        }
        
        if entity == .Items {
            let item = object as! Items
            item.item = value
            item.lastUpdatedDate = Date()
            saveContext()
        }
    }
    
    func updateOrderAfterDelete<T: NSManagedObject>(objects: [T], entity: Entity) {
        if entity == .List {
            for (index, list) in objects.enumerated() {
                let title = list as! List
                title.order = Int32(index)
                title.lastUpdateDate = Date()
                saveContext()
            }
        }
        if entity == .Items {
            for (index, currentItem) in objects.enumerated() {
                let item = currentItem as! Items
                item.order = Int32(index)
                item.lastUpdatedDate = Date()
                saveContext()
            }
        }
    }
    
    func updateSectionItemsOrder<T: NSManagedObject>(objects: [T], entity: Entity) {
           if entity == .Items {
               for (index, currentItem) in objects.enumerated() {
                   let item = currentItem as! Items
                   item.order = Int32(index)
                   item.lastUpdatedDate = Date()
                   saveContext()
               }
           }
       }
    
    
    //MARK - Save Context
    func saveContext() {
        if managedObjectContext.hasChanges {
            managedObjectContext.performAndWait {
                do {
                    try self.managedObjectContext.save()
                }
                catch let error as NSError {
                    fatalError("WriteToDatabaseProtocol - Save MOC Failed \(error.localizedDescription)")
                }
            }
        }
    }
    
    //MARK: - Delete
    func deleteFromCoreData(object: NSManagedObject) {
        managedObjectContext.delete(object)
        saveContext()
    }
}

