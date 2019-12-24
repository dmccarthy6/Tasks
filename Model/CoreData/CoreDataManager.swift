//
//  CoreDataManager.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import CoreData
import TasksFramework

class CoreDataManager: NSObject  {
    
    
    //MARK: Properties
    public static let shared = CoreDataManager(){}
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var mainThreadManagedObjectContext: NSManagedObjectContext
    fileprivate let coordinator: NSPersistentStoreCoordinator?
    var list: List?
    var items: [Items] = []
    let fileManager = FileManager.default
    let storeName = "Tasks.sqlite"
    
    
    
    init(closure: @escaping () -> ()) {
        
        if #available(iOS 13.0, *) {
            coordinator = nil
            mainThreadManagedObjectContext = CoreDataAndCloudKit.shared.mainThreadManagedObjectContext
        } else {
            coordinator = DataAccess.shared.coordinator
            mainThreadManagedObjectContext = DataAccess.shared.mainThreadManagedObjectContext
        }
       
        super.init()
        
    }
    
    //DATABASE FUNCTIOONS:
    
    //MARK: - Save Functions
    func save() {
        let insertedObjects = mainThreadManagedObjectContext.insertedObjects
        let modifiedObjects = mainThreadManagedObjectContext.updatedObjects
        //let deletedRecordIDs = mainThreadManagedObjectContext.deletedObjects.compactMap{ ($0 as? CloudKitManagedObject)?.cloudKitRecordID() }
        
        if mainThreadManagedObjectContext.hasChanges { //privateObjectContext.hasChanges ||
            self.mainThreadManagedObjectContext.performAndWait {
                do {
                    try self.mainThreadManagedObjectContext.save()
                }
                catch let error as NSError {
                    fatalError("CoreDataManager = Save MOC failed: \(error.localizedDescription)")
                }
               
                let insertedManagedObjectIDs = insertedObjects.compactMap{ $0.objectID }
                let modifiedManagedObjectIDs = modifiedObjects.compactMap{ $0.objectID }
            }
        }
    }
    
    
    //MARK: - Save List Title & List Items
    func saveTitleToCoreData(title: String?, order: Int, entity: Entity) {
        guard let title = title else {
            fatalError("SaveTitleToCoreData - Guard Statement Failed for No Valid Input")
        }
        guard let addedTitle = NSEntityDescription.insertNewObject(forEntityName: entity.rawValue, into: mainThreadManagedObjectContext) as? List else {
            fatalError("SaveTitleToCoreData - Could Not Add New Item")
        }
        
        //Create record UUID, convert to data to store to Core Data
        let titleUUID = UUID().uuidString
        let uuidAsData = titleUUID.data(using: .utf8) as Data?
        
        addedTitle.title = title
        addedTitle.order = Int32(order)
        addedTitle.recordID = uuidAsData
        addedTitle.dateAdded = Date()
        addedTitle.lastUpdateDate = Date()
        addedTitle.isCompleted = false
        
        list = addedTitle
        save()
    }
    
    func saveItemsToCoreData(list: List, item: String?, entity: Entity) {
        guard let item = item else {
            fatalError("SaveItemsToCoreData - Item is nil")//Alert HERE? Return,  item is Nil
        }
        
        guard let addedItem = NSEntityDescription.insertNewObject(forEntityName: entity.rawValue, into: mainThreadManagedObjectContext) as? Items else {
            fatalError("SaveItemsToCoreData - Could Not Add New Item")
        }
        //let items = list.items?.allObjects as? [Items]
        let items = [list.items]
        let order: Int32 = Int32(items.count ?? 0)
        
        let itemUUID = UUID().uuidString
        let uuidAsData = itemUUID.data(using: .utf8) as Data?
        
        addedItem.list = list
        print("CoreDataManager - Save Items - ITEM LIST \(list)")
        addedItem.order = order
        addedItem.item = item
        addedItem.titleID = convertIDToString(id: list.recordID!)
        addedItem.recordID = uuidAsData
        addedItem.dateAdded = Date()
        addedItem.lastUpdatedDate = Date()
        addedItem.isComplete = false
        addedItem.isFlagged = false
        addedItem.updateSectionIdentifier()
        
        self.items.append(addedItem)
        save()
    }
    
    func convertIDToString(id: Data) -> String {
        let IDString = String(data: id, encoding: .utf8)
        
        if let stringID = IDString {
            return stringID
        }
        else { return "" }
    }
    
    
    
    //MARK: - Set Alerts &/Or Due Dates
    func setItemAlert(item: Items, alert: Date) {
        item.reminderDate = alert.dateOnlyToString(date: alert)
        item.lastUpdatedDate = Date()
        save()
        Notifications.shared.createNotification(from: alert, item: item)
    }
    
    func setDueDate(item: Items, date: Date) {
        let dueDate = date
        let stringDate = dueDate.dateOnlyToString(date: dueDate)
        item.dueDate = stringDate
        item.lastUpdatedDate = Date()
        save()
    }
    
    //MARK: - Set Completed or Favorite Status
    func setCompletedStatus(item: Items) {
        let currentStatus = item.isComplete
        
        item.isComplete = !currentStatus
        item.reminderDate = ""
        item.updateSectionIdentifier()
        item.lastUpdatedDate = Date()
        save()
    }
    
    func setItemFavorite(item: Items, status: Bool) {
        item.isFlagged = status
        item.lastUpdatedDate = Date()
        save()
    }
    
    //MARK: - Update Titles & Items
    func updateItem(item: Items, text: String?) {
        if let itemText = text {
            item.item = itemText
        }
        item.updateSectionIdentifier()
        item.lastUpdatedDate = Date()
        save()
    }
    
    func updateListTitle(list: List, newTitle: String) {
        list.title = newTitle
        list.lastUpdateDate = Date()
        save()
    }
    
    //MARK: - Perform Full Sync
//    func sync() {
//        cloudKitManager?.performFullSync()
//    }
//
//    //MARK: - Fetch CloudKitManagedObjects from Core Data using NSManagedObjectID
//    func fetchCloudKitManagedObjects(managedObjectContext: NSManagedObjectContext, managedObjectIDs: [NSManagedObjectID]) -> [CloudKitManagedObject] {
//        var cloudKitManagedObjects: [CloudKitManagedObject] = []
//
//        for managedObjectID in managedObjectIDs {
//            do {
//                let managedObject = try managedObjectContext.existingObject(with: managedObjectID)
//                if let cloudKitManagedObject = managedObject as? CloudKitManagedObject {
//                    cloudKitManagedObjects.append(cloudKitManagedObject)
//                }
//            }
//            catch let error as NSError {
//                print("CoreDataManager - Error Fetching CoreData: \(error.localizedDescription)")
//            }
//        }
//        return cloudKitManagedObjects
//    }
    
    //MARK: - Batch Delete
    func batchDeleteCoreData(entityName: Entity) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try mainThreadManagedObjectContext.execute(batchDeleteRequest)
            self.save()
            
        } catch {
            //Error Handling
        }
    }
    
}//CLASS


