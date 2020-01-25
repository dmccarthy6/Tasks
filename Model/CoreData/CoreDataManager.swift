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

/* Use this class to bridge the CoreData Context from the Widgets/Framwwork to the Main target. */

class CoreDataManager: NSObject, CanWriteToDatabase  {
    
    //MARK: Properties
    public static let shared = CoreDataManager(){}
    var mainThreadManagedObjectContext: NSManagedObjectContext
    fileprivate let coordinator: NSPersistentStoreCoordinator?
    
    
    //MARK: - Initializer
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
    
    
    //MARK: - Batch Delete
    func batchDeleteCoreData(entityName: Entity) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try mainThreadManagedObjectContext.execute(batchDeleteRequest)
            self.saveContext()
            
        } catch {
            //Error Handling
        }
    }
    
}//CLASS


