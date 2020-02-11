
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//
import UIKit
import CoreData
import TasksFramework

//typalias Database = ReadFromDatabase & WriteToDatabase --IN VC

@objc protocol CanReadFromDatabase {
    var listsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? { get set }
    var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? { get set }
    var completedItemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? { get set }
}

extension CanReadFromDatabase {
    var managedObjectContext: NSManagedObjectContext {
        get { return CoreDataManager.shared.mainThreadManagedObjectContext }
    }
    
    
    func configureListsController() {
        let listsController = ListFetchedResultsController(managedObjectContext: managedObjectContext)
        let configuredListsController = listsController.configureListsController()
        listsFetchedResultsController = configuredListsController
    }
    
    func configureReadItemsController(predicate: NSPredicate) {
        let itemsController = ItemsFetchedResultsController(managedObjectContext: managedObjectContext, predicate: predicate)
        let configuredController = itemsController.configureItemsController()
        itemsFetchedResultsController = configuredController
    }
    
    //MARK: Fetch Lists Functions
    func fetchSingleList(indexPath: IndexPath, id: String) -> List? {
        if let controller = listsFetchedResultsController {
            let list = controller.object(at: indexPath) as! List
            return list
        }
        return nil
    }
    
    func getListAtIndexPath(indexPath: IndexPath) -> List? {
        if let controller = listsFetchedResultsController {
            let fetchedResultsIndexPath = IndexPath(row: indexPath.row, section: 0)
            let list = controller.object(at: fetchedResultsIndexPath) as! List
            return list
        }
        else { return nil }
    }
    
    func getListsCount() -> Int {
        let lists = listsFetchedResultsController?.fetchedObjects as! [List]
        return lists.count
    }
    
    func getObjectsAtSection(section: Int, frcSection: Int) -> Int? {
        let fetchedResultsSection = frcSection
        
        if let listsFRC = listsFetchedResultsController {
            let dataAtSection = listsFRC.sections![fetchedResultsSection]
            return dataAtSection.objects?.count ?? 0
        }
        if let openItemsFRC = itemsFetchedResultsController {
            let itemsAtSection = openItemsFRC.sections![fetchedResultsSection]
            return itemsAtSection.objects?.count ?? 0
        }
        if let closedItemsFRC = completedItemsFetchedResultsController {
            let completedItemsAtSection = closedItemsFRC.sections![fetchedResultsSection]
            return completedItemsAtSection.objects?.count ?? 0
        }
        return nil
    }
       
//ITEMS CONTROLLER
    func getListID(indexPath: IndexPath) -> String {
        let list = getListAtIndexPath(indexPath: indexPath)
        if let id = list?.recordID {
            let stringID = String(data: id, encoding: String.Encoding.utf8)
            return stringID!
        }
        return ""
    }
    
    func setDelegate(tableView: UITableView) -> ItemsFetchedResultsControllerDelegate {
        let delegate = ItemsFetchedResultsControllerDelegate(tableView: tableView)
        return delegate
    }
    
    //MARK: - Widget Functions
    func configureControllerOpenedByWidget(id: String) -> ItemsController {
        let controller = ItemsController(id: id)
        configureReadItemsController(predicate: NSPredicate(format: "titleID == %@", id))
        return controller
    }
    
//    func getListFromTitleID(id: String) -> List {
//        
//        let listsArray = configureControllerOpenedByWidget(id: id).fetchedObjects as? [List]
//        let stringData = id.data(using: String.Encoding.utf8)
//        let itemToReturn = listsArray?.filter({ $0.recordID == stringData })
//        return itemToReturn![0]
//    }
}

/*
 private func configureController() {
     itemsController = ItemsController(id: String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)!)
     itemsController.delegate = fetchedResultsControllerDelegate
     let id = String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)
     let pred = NSPredicate(format: "titleID == %@", id!)
     configureReadItemsController(predicate: pred)
 }
 */
