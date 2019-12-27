//
//  ItemsController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import CoreData

class ItemsController: NSObject, CanReadFromDatabase {
    var listsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var completedItemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var delegate: NSFetchedResultsControllerDelegate?
    fileprivate var oldSectionsDuringFetchUpdate: [ControllerSectionInfo] = []
    var sections: [ControllerSectionInfo]?
    var id: String
    fileprivate lazy var itemsController: NSFetchedResultsController<NSFetchRequestResult> = {
         let itemsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Items.rawValue)
         itemsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "sectionIdentifier", ascending: true), NSSortDescriptor(key: "order", ascending: false)]
         itemsFetchRequest.predicate = NSPredicate(format: "titleID == %@", self.id)
         itemsFetchedResultsController = NSFetchedResultsController(fetchRequest: itemsFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
         
         itemsFetchedResultsController?.delegate = self
         do {
             try itemsFetchedResultsController?.performFetch()
         }
         catch let error as NSError {
             print("Error Fetchinng \(error)")
         }
         return itemsFetchedResultsController!
     }()
    
    init(id: String) {
        self.id = id
        super.init()
        sections = setSections()
    }
    
    func fetchItems() -> [Items] {
        let items = itemsController.fetchedObjects as? [Items]
        return items?.map{ $0 } ?? []
    }
    
    func itemsControllerItemAtIndexPath(indexPath: IndexPath, sections: [ControllerSectionInfo]) -> Items? {
        let sectionInfo = sections[indexPath.section]
        if let section = sectionInfo.fetchedIndex {
            let indexPath = IndexPath(row: indexPath.row, section: section)
            let itemAtIndexPath = itemsFetchedResultsController?.object(at: indexPath) as! Items
            return itemAtIndexPath
        }
        return nil
    }
    
    func allItemsAreComplete() -> Bool {
        let openItems = fetchItems().filter({ $0.isComplete == false }).count
        let closedItems = fetchItems().filter({ $0.isComplete }).count
        
        if openItems == 0 && closedItems > 0 { return true }
        else {
            return false
        }
    }
    
    func showCompletedButton() -> Int {
        if fetchItems().filter({ $0.isComplete }).count > 0 {
            return 1
        }
        else { return 0 }
    }
    
    func getCompletedItemsCount() -> Int {
        let completedCount = fetchItems().filter({ $0.isComplete }).count
        return completedCount
    }
    
    func numberOfSectionsBasedOnItemStatus() -> Int {
        if fetchItems().filter({ $0.isComplete }).count > 0 {
            return 3
        }
        else {
            return 2
        }
    }
    
    //MARK: - Private Functions
    fileprivate func setSections() -> [ControllerSectionInfo]? {
        guard let fetchedSections = itemsController.sections?.map({ $0.name }) else { return [] }
        
        let sectionValuesIndexes = fetchedSections.map({ ($0, fetchedSections.firstIndex(of: $0)) })
        let sections = sectionValuesIndexes.map({ ControllerSectionInfo(section: ItemsSection(rawValue: $0.0)!, fetchedIndex: $0.1, fetchController: itemsController) })
       return sections
    }
    
    fileprivate func displayedIndexPathForFetchedIndexPath(_ fetchedIndexPath: IndexPath, sections: [ControllerSectionInfo])  -> IndexPath? {
        for (sectionIndex, sectionInfo) in sections.enumerated() {
            if sectionInfo.fetchedIndex == fetchedIndexPath.section {
                return IndexPath(row: fetchedIndexPath.row, section: sectionIndex)
            }
        }
        return nil
    }
}

extension ItemsController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        oldSectionsDuringFetchUpdate  = sections ?? [] //Backup //= sections --Setting the variable here
        delegate?.controllerWillChangeContent?(controller)
    }


    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        //When we show empty sections, fetched section changes don't affect our delegate
        sections = setSections()
        let section = getTableViewSection(from: sectionIndex)
        delegate?.controller?(controller, didChange: sectionInfo, atSectionIndex: section, for: type)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            print("IP: \(newIndexPath.section), \(newIndexPath.row)")
            let indexPathToUse = updateTableViewIndexPath(from: newIndexPath)
            print("IP TO USE: \(indexPathToUse.section), \(indexPathToUse.row)")
            delegate?.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: indexPathToUse)
            print("ItemsController- Insert IndexPath - \(indexPathToUse)")
            
        case .update:
            let item = anObject as! Items
            let displayedOldIndexPath = indexPath.flatMap{ displayedIndexPathForFetchedIndexPath($0, sections: oldSectionsDuringFetchUpdate) }
            let displayedNewIndexPath = indexPath.flatMap{ displayedIndexPathForFetchedIndexPath($0, sections: sections ?? []) }
            delegate?.controller?(controller, didChange: item, at: displayedOldIndexPath, for: type, newIndexPath: displayedNewIndexPath)
            
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath, let anObject = anObject as? Items {
                let openItemsCount = fetchItems().filter({ $0.isComplete == false }).count
                let completedItemsCount = fetchItems().filter({ $0.isComplete }).count
                let oldsectionsCount = oldSectionsDuringFetchUpdate.count //This is FRC Sections, 2 means there are open and closed
                let newSectionsCount = sections?.count
                
                if oldsectionsCount == 1 && newSectionsCount == 2 {
                    //Moving the First Item from closed to open
                    handleOpenItems(in: controller, indexPath: indexPath, newIndexPath: newIndexPath, object: anObject, type: type)
                }
                else if oldsectionsCount == 2 && newSectionsCount == 1 {
                    //2 things can happen here - moving last open item to closed || moving last closed item to open
                    if openItemsCount == 0 {
                        //Moving Last Open Item To Closed
                        handleOpenItems(in: controller, indexPath: indexPath, newIndexPath: newIndexPath, object: anObject, type: type)
                    }
                    if completedItemsCount == 0 {
                        //Moving last closed Item to Open
                        handleChange(controller: controller, object: anObject, oldIndex: indexPath, type: type, newIndex: newIndexPath)
                    }
                }
                //This gets called when moving from open to closed or closed to open, if not the last item.
                handleChange(controller: controller, object: anObject, oldIndex: indexPath, type: type, newIndex: newIndexPath)
            }
        case .delete:
            print("DELETE")
            if let indexPath = indexPath {
                delegate?.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
            }
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent?(controller)
    }

    //MARK: - Helper functions
    func getTableViewSection(from controllerIndex: Int) -> Int {
        switch controllerIndex {
        case 0:     return 1
        case 1:     return 3
        case 2:     return 1
        default:    return 1
        }
    }

    func updateTableViewIndexPath(from controllerIndexPath: IndexPath) -> IndexPath {
        switch controllerIndexPath.section {
        case 0: return IndexPath(row: controllerIndexPath.row, section: 1)
        case 1: return IndexPath(row: controllerIndexPath.row, section: 3)
        case 2: return IndexPath(row: controllerIndexPath.row, section: 1)
        default: return IndexPath(row: controllerIndexPath.row, section: 1)
        }
    }
   
    func handleChange(controller: NSFetchedResultsController<NSFetchRequestResult>, object: Any, oldIndex: IndexPath, type: NSFetchedResultsChangeType, newIndex: IndexPath) {
        let tableViewIndexPath = updateTableViewIndexPath(from: oldIndex)
        let tableViewNewIndexPath = updateTableViewIndexPath(from: newIndex)
        print("ItemsController - Moving item from \(tableViewIndexPath.section), row: \(tableViewIndexPath.row) to Newsection: \(tableViewNewIndexPath.section), Newrow: \(tableViewNewIndexPath.row)")
        delegate?.controller?(controller, didChange: object, at: tableViewIndexPath, for: type, newIndexPath: tableViewNewIndexPath)
    }
    
    func handleOpenItems(in controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath, newIndexPath: IndexPath, object: Any, type: NSFetchedResultsChangeType) {
        let openItemsCount = fetchItems().filter({ $0.isComplete == false }).count
        let closedItemsCount = fetchItems().filter({ $0.isComplete }).count
        
        if openItemsCount == 0 {
            //All Items Are Closed, adjust TableView Accordingly
            let currentIndex = updateTableViewIndexPath(from: indexPath)
            let destinationIndex = IndexPath(row: newIndexPath.row, section: 2)
            print("ItemsController - Moving last item from open to closed; From: \(currentIndex.section), \(currentIndex.row) to \(destinationIndex.section), \(destinationIndex.row)")
            delegate?.controller?(controller, didChange: object, at: currentIndex, for: type, newIndexPath: destinationIndex)
        }
        if openItemsCount == 1 {
            switch oldSectionsDuringFetchUpdate.count {
            case 1:
                if newIndexPath.section == 0 {
                    //Moving First Item from Closed to Reopened;
                    let currentIndexPath = IndexPath(row: indexPath.row, section: 2)
                    let destinationIndexPath = IndexPath(row: newIndexPath.row, section: 1)
                    delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
                }
                else if newIndexPath.section == 1 {
                    //Moving first item to closed if only two items in open section
                    let currentIndexPath = updateTableViewIndexPath(from: indexPath)
                    let destinationIndexPath = updateTableViewIndexPath(from: newIndexPath)
                    delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
                }
            case 2:
                //Moving item from open to closed -> When closed section exists
                let currentIndexPath = updateTableViewIndexPath(from: indexPath)
                let destinationIndexPath = updateTableViewIndexPath(from: newIndexPath)
                delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
                
            default: print("Default")
            }
        }
    }
    
}//

//            if oldSectionsDuringFetchUpdate.count == 1 && newIndexPath.section == 0 {
//                //First Item Moving from All Closed to Reopen
//                let currentIndex = IndexPath(row: indexPath.row, section: 2)
//                let destinationIndex = IndexPath(row: newIndexPath.row, section: 1)
//                delegate?.controller?(controller, didChange: object, at: currentIndex, for: type, newIndexPath: destinationIndex)
//            }
//            if oldSectionsDuringFetchUpdate.count == 2 {
//                let originIndex = updateTableViewIndexPath(from: indexPath)
//                let destinationIndex = updateTableViewIndexPath(from: newIndexPath)
//                print("Moving from: [\(originIndex.section), \(originIndex.row)], TO: [\(destinationIndex.section), \(destinationIndex.row)]")
//                delegate?.controller?(controller, didChange: object, at: originIndex, for: type, newIndexPath: destinationIndex)
//            }
//            if oldSectionsDuringFetchUpdate.count == 1 && newIndexPath.section == 1 {
//                //If two items in Open, Move to closed
//                let current = updateTableViewIndexPath(from: indexPath)
//                let next = updateTableViewIndexPath(from: newIndexPath)
//                delegate?.controller?(controller, didChange: object, at: current, for: type, newIndexPath: next)
//            }

/*
 class ItemsController: NSObject {
     
     fileprivate(set) var sections: [ControllerSectionInfo] = []
     var delegate: NSFetchedResultsControllerDelegate?
     fileprivate var oldSectionsDuringFetchUpdate: [ControllerSectionInfo] = []
     fileprivate var managedObjectContext: NSManagedObjectContext
     
     var id: String
     fileprivate lazy var itemsController: NSFetchedResultsController<NSFetchRequestResult> = {
         let itemsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Items.rawValue)
         itemsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "sectionIdentifier", ascending: true), NSSortDescriptor(key: "order", ascending: true)]
         itemsFetchRequest.predicate = NSPredicate(format: "titleID == %@", self.id)
         let controller = NSFetchedResultsController(fetchRequest: itemsFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
         
         controller.delegate = self
         do {
             try controller.performFetch()
         }
         catch let error as NSError {
             print("Error Fetchinng \(error)")
         }
         return controller
     }()
     
     
     init(managedObjectContext: NSManagedObjectContext, id: String) {
         self.managedObjectContext = managedObjectContext
         self.id = id
         
         super.init()
         sections = setSections() ?? []
     }
     
     //MARK: Methods
     
     func fetchItems() -> [Items] {
         let items = itemsController.fetchedObjects as? [Items]
         return items?.map{ $0 } ?? []
     }
     
     func itemAtIndexPath(_ indexPath: IndexPath) -> Items? {
         let sectionInfo = sections[indexPath.section]
         
         guard let section = sectionInfo.fetchedIndex else { return nil }
         let indexPath = IndexPath(row: indexPath.row, section: section)
         let itemAtIndexPath = itemsController.object(at: indexPath) as? Items
         return itemAtIndexPath
     }
     
     func reloadData() {
         try! itemsController.performFetch()
         sections = setSections() ?? []
     }
     
     
     //MARK: Private Methods
     fileprivate func setSections() -> [ControllerSectionInfo]? {
         guard let fetchedSections = itemsController.sections?.map({ $0.name }) else { return [] }
         
         let sectionValuesIndexes = fetchedSections.map({ ($0, fetchedSections.firstIndex(of: $0)) })
         let sections = sectionValuesIndexes.map({ ControllerSectionInfo(section: ItemsSection(rawValue: $0.0)!, fetchedIndex: $0.1, fetchController: itemsController) })
        return sections
     }
     func notifyDelegateOfChangesEmptySections(_ changedSections: [ControllerSectionInfo], changeType: NSFetchedResultsChangeType) {
         for (index, sectionInfo) in changedSections.enumerated() {
             if sectionInfo.fetchedIndex == nil {
                 delegate?.controller?(itemsController, didChange: sectionInfo, atSectionIndex: index, for: changeType)
             }
         }
         
     }
     
     fileprivate func displayedIndexPathForFetchedIndexPath(_ fetchedIndexPath: IndexPath, sections: [ControllerSectionInfo])  -> IndexPath? {
         for (sectionIndex, sectionInfo) in sections.enumerated() {
             if sectionInfo.fetchedIndex == fetchedIndexPath.section {
                 return IndexPath(row: fetchedIndexPath.row, section: sectionIndex)
             }
         }
         return nil
     }
 }
 extension ItemsController: NSFetchedResultsControllerDelegate {
     func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         oldSectionsDuringFetchUpdate = sections //Backup
         delegate?.controllerWillChangeContent?(controller)
     }
     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
         //When we show empty sections, fetched section changes don't affect our delegate
         sections = setSections() ?? []
         let section = getTableViewSection(from: sectionIndex)
         delegate?.controller?(controller, didChange: sectionInfo, atSectionIndex: section, for: type)
     }
     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
         switch type {
         case .insert:
             guard let newIndexPath = newIndexPath else { return }
             let indexPathToUse = updateTableViewIndexPath(from: newIndexPath)
             delegate?.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: indexPathToUse)
             print(indexPathToUse)
             
         case .update:
             let item = anObject as! Items
             let displayedOldIndexPath = indexPath.flatMap{ displayedIndexPathForFetchedIndexPath($0, sections: oldSectionsDuringFetchUpdate) }
             let displayedNewIndexPath = indexPath.flatMap{ displayedIndexPathForFetchedIndexPath($0, sections: sections) }
             delegate?.controller?(controller, didChange: item, at: displayedOldIndexPath, for: type, newIndexPath: displayedNewIndexPath)
             
         case .move:
             print("MOVE")
             if let indexPath = indexPath, let newIndexPath = newIndexPath, let anObject = anObject as? Items {
                 let openItemsCount = (itemsController.fetchedObjects as? [Items])?.filter({ $0.isComplete == false }).count
                 if openItemsCount == 0 || openItemsCount == 1 {
                    handleOpenItems(in: controller, indexPath: indexPath, newIndexPath: newIndexPath, object: anObject, type: type)
                 } else {
                     let tableViewIndexPath = updateTableViewIndexPath(from: indexPath)
                     let tableViewNewIndexPath = updateTableViewIndexPath(from: newIndexPath)
                     print("ItemsController - Moving item from \(tableViewIndexPath.section), row: \(tableViewIndexPath.row) to Newsection: \(tableViewNewIndexPath.section), Newrow: \(tableViewNewIndexPath.row)")
                     delegate?.controller?(controller, didChange: anObject, at: tableViewIndexPath, for: type, newIndexPath: tableViewNewIndexPath)
                 }
             }
         case .delete:
             print("DELETE")
             if let indexPath = indexPath {
                 delegate?.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
             }
         }
     }
     func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         delegate?.controllerDidChangeContent?(controller)
     }
     func getTableViewSection(from controllerIndex: Int) -> Int {
         switch controllerIndex {
         case 0:     return 1
         case 1:     return 3
         case 2:     return 1
         default:    return 1
         }
     }
     func updateTableViewIndexPath(from controllerIndexPath: IndexPath) -> IndexPath {
         switch controllerIndexPath.section {
         case 0: return IndexPath(row: controllerIndexPath.row, section: 1)
         case 1: return IndexPath(row: controllerIndexPath.row, section: 3)
         case 2: return IndexPath(row: controllerIndexPath.row, section: 1)
         default: return IndexPath(row: controllerIndexPath.row, section: 1)
         }
     }
    
     func handleOpenItems(in controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath, newIndexPath: IndexPath, object: Any, type: NSFetchedResultsChangeType) {
         let openItemsCount = (itemsController.fetchedObjects as? [Items])?.filter({ $0.isComplete == false }).count
         let closedItemsCount = (itemsController.fetchedObjects as? [Items])?.filter({ $0.isComplete }).count
         
         
         if openItemsCount == 0 {
             //All Items Are Closed, adjust TableView Accordingly
             let currentIndex = updateTableViewIndexPath(from: indexPath)
             let destinationIndex = IndexPath(row: newIndexPath.row, section: 2)
             print("ItemsController - Moving last item from open to closed; From: \(currentIndex.section), \(currentIndex.row) to \(destinationIndex.section), \(destinationIndex.row)")
             delegate?.controller?(controller, didChange: object, at: currentIndex, for: type, newIndexPath: destinationIndex)
         }
         if openItemsCount == 1 {
             switch oldSectionsDuringFetchUpdate.count {
             case 1:
                 if newIndexPath.section == 0 {
                     //MARK: - Moving First Item from Closed to Reopened;
                     let currentIndexPath = IndexPath(row: indexPath.row, section: 2)
                     let destinationIndexPath = IndexPath(row: newIndexPath.row, section: 1)
                     delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
                 }
                 else if newIndexPath.section == 1 {
                     //MARK: - Moving first item to closed if only two items in open section
                     let currentIndexPath = updateTableViewIndexPath(from: indexPath)
                     let destinationIndexPath = updateTableViewIndexPath(from: newIndexPath)
                     delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
                 }
             case 2:
                 //MARK: - Moving item from open to closed -> When closed section exists
                 let currentIndexPath = updateTableViewIndexPath(from: indexPath)
                 let destinationIndexPath = updateTableViewIndexPath(from: newIndexPath)
                 delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
                 
             default: print("Default")
             }
             //            if oldSectionsDuringFetchUpdate.count == 1 && newIndexPath.section == 0 {
             //                //First Item Moving from All Closed to Reopen
             //                let currentIndex = IndexPath(row: indexPath.row, section: 2)
             //                let destinationIndex = IndexPath(row: newIndexPath.row, section: 1)
             //                delegate?.controller?(controller, didChange: object, at: currentIndex, for: type, newIndexPath: destinationIndex)
             //            }
             //            if oldSectionsDuringFetchUpdate.count == 2 {
             //                let originIndex = updateTableViewIndexPath(from: indexPath)
             //                let destinationIndex = updateTableViewIndexPath(from: newIndexPath)
             //                print("Moving from: [\(originIndex.section), \(originIndex.row)], TO: [\(destinationIndex.section), \(destinationIndex.row)]")
             //                delegate?.controller?(controller, didChange: object, at: originIndex, for: type, newIndexPath: destinationIndex)
             //            }
             //            if oldSectionsDuringFetchUpdate.count == 1 && newIndexPath.section == 1 {
             //                //If two items in Open, Move to closed
             //                let current = updateTableViewIndexPath(from: indexPath)
             //                let next = updateTableViewIndexPath(from: newIndexPath)
             //                delegate?.controller?(controller, didChange: object, at: current, for: type, newIndexPath: next)
             //            }
         }
         
         
     }//oo
     
 }//
 */
