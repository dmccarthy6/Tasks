//
//  ListsFRC.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import CoreData

struct ListFetchedResultsController {

    var managedObjectContext: NSManagedObjectContext
    
    func configureListsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let listFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.List.rawValue)
        listFetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        listFetchRequest.predicate = NSPredicate(value: true)
        
        let listFetchedResultsController = NSFetchedResultsController(fetchRequest: listFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try listFetchedResultsController.performFetch()
        }
        catch let error {
            
            print("Error Fetching Lists: \(error)")
        }
        return listFetchedResultsController
    }

}
