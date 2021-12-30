//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import CoreData

class ConfigureFetchedResultsController {
    
    //MARK: - Properties
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    private var coreDataManager: CoreDataManager
    
    
    //MARK: - Initializer
    init(coreDataManager: CoreDataManager, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchedResultsController = fetchedResultsController
        self.coreDataManager = coreDataManager
        
    }
    
    
    //MARK: - Helpers
    func configureFetchedResultsController(entityName: String, predicate: NSPredicate) -> NSFetchedResultsController<NSFetchRequestResult>? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortOrder = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortOrder]
        fetchRequest.predicate = predicate
        let managedObjectContext = CoreDataManager.shared.ckContainerContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController
        }
        catch let error as NSError {
            print("CONFIGUREFETCHEDRESULTSCONTROLLER - Error Fetching: \(error.localizedDescription)")
        }
        return nil
    }
    
}
