////  Created by Dylan  on 12/3/19.
////  Copyright © 2019 Dylan . All rights reserved.
////
//
//import UIKit
//import CoreData
//import TasksFramework
//
//
//class WidgetFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
//    //MARK: - Properties
//    
//    private var tableView: UITableView!
//    private lazy var widgetController: NSFetchedResultsController<NSFetchRequestResult> = {
//        //Predicates
//        let todayRemindersPredicate = DatesPredicate.reminderDateIsTodayPredicate()
//        let allPredicate = NSPredicate(value: true)
//        
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntity.Items.rawValue)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "reminderDate", ascending: true)]//reminderDate
//        fetchRequest.predicate = allPredicate //todayRemindersPredicate
//        
//        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.context, sectionNameKeyPath: nil, cacheName: nil)
//        controller.delegate = self
//        return controller
//        
//    }()
//    var initialCount: Int?
//    
//    
//    
//    
//    //MARK: - Initializer
//    init(tableView: UITableView) {
//        self.tableView = tableView
//        super.init()
//    }
//    
//    ///
//    func configureController() {
//        do {
//            try widgetController.performFetch()
//        }
//        catch let error as NSError {
//            print("Error Fething Widget Controller: \(error.localizedDescription)")
//        }
//    }
//    
//    //MARK: - Helpers
//    func fetchAllReminderItems() -> [Items] {
//        if let items = widgetController.fetchedObjects as? [Items] {
//            return items
//        }
//        else { return [] }
//    }
//    
//    func getItem(at indexPath: IndexPath) -> Items {
//        let item = widgetController.object(at: indexPath) as! Items
//        return item
//    }
//}
//
////MARK: - FetchedResultsController Delegate Methods
//extension WidgetFetchedResultsController: NSFetchedResultsControllerDelegate {
//    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.beginUpdates()
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            print("Widget Delegate -- Insert Item")
//            guard let newIndexPath = newIndexPath else {
//                return
//            }
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
//            
//        case .update:
//            if let indexPath = indexPath, let managedObject = anObject as? Items, let item = managedObject.item {
//                if let reminderItemCell = tableView.cellForRow(at: indexPath) as? WidgetCell {
//                    reminderItemCell.configureWidgetCellText(text: item, isFlagged: managedObject.isFlagged, isComplete: managedObject.isComplete)
//                }
//                tableView.reloadRows(at: [indexPath], with: .fade)
//            }
//            
//        case .delete:
//            if let indexPath = indexPath {
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//            
//        case .move:
//            if let indexPath = indexPath, let newIndexPath = newIndexPath {
//                tableView.moveRow(at: indexPath, to: newIndexPath)
//            }
//            
//        @unknown default:()
//        }
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.endUpdates()
//    }
//}
//
////MARK: - Core Data Enums
enum CoreDataEntity: String {
    case List = "List"
    case Items = "Items"
}
//
//enum CoreDataError: Error {
//    case noData
//    case failedToFetch
//    
//    var localizedDescription: String {
//        switch self {
//        case .noData:           return "No Data"
//        case .failedToFetch:     return "Failure Fetching Data"
//        }
//    }
//}
//
////    func fetchReminderItems() throws -> [AnyObject] {
////        var itemData = Dictionary<String, AnyObject>()
////        var itemsToReturn = [AnyObject]()
////
////        if let results = widgetController.fetchedObjects as? [NSManagedObject] {
////            print("Data Count: \(results.count)")
////            var count = 0
////            while count < results.count {
////                let match = results[count] as NSManagedObject
////                itemData = [
////                    ItemsKey.List.rawValue : match.value(forKey: ItemsKey.List.rawValue) as AnyObject,
////                    ItemsKey.Item.rawValue : match.value(forKey: ItemsKey.Item.rawValue) as AnyObject,
////                    ItemsKey.RecordID.rawValue : match.value(forKey: ItemsKey.RecordID.rawValue) as AnyObject,
////                    ItemsKey.TitleID.rawValue : match.value(forKey: ItemsKey.TitleID.rawValue) as AnyObject,
////                    ItemsKey.ReminderDate.rawValue : match.value(forKey: ItemsKey.ReminderDate.rawValue) as AnyObject,
////                    ItemsKey.IsComplete.rawValue : match.value(forKey: ItemsKey.IsComplete.rawValue) as AnyObject,
////                    ItemsKey.IsFlagged.rawValue : match.value(forKey: ItemsKey.IsFlagged.rawValue) as AnyObject
////                ]
////                itemsToReturn.append(itemData as AnyObject)
////                count += 1
////            }
////            return itemsToReturn
////        }
////        else {
////            throw CoreDataError.failedToFetch
////        }
////    }
