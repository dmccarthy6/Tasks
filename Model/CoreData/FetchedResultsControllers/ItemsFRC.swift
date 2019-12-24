//
//  ItemsFRC.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import CoreData

struct ItemsFetchedResultsController {
    var managedObjectContext: NSManagedObjectContext
    var predicate: NSPredicate
    
    func configureItemsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let itemsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Items.rawValue)
        
        itemsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "sectionIdentifier", ascending: true), NSSortDescriptor(key: "order", ascending: true)]
        itemsFetchRequest.predicate = predicate
        
        let itemsFetchedResultsController = NSFetchedResultsController(fetchRequest: itemsFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
        
        //TO-DO: Set Delegate
        
        do {
            try itemsFetchedResultsController.performFetch()
        }
        catch let error as NSError {
            print("Error Fetching Core Data: \(error)")
        }
        return itemsFetchedResultsController
    }
    
}
