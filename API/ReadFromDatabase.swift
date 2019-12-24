//
//  ReadFromDatabase.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//
import UIKit
import CoreData

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
    
//    func itemsForSection(section: Int) -> Int {
//        if fetchItems().count > 0 {
//            return sections[section].numberOfObjects
//        }
//        return 0
//    }
//
//    func completedItemsForSection(section: Int) -> Int {
//        return sections[section].numberOfObjects
//    }
//
//    func returnItemsSectionsCount() -> Int {
//        return sections.count
//    }
    
//    func allItemsAreComplete() -> Bool {
//        let openItems = fetchItems().filter({ $0.isComplete == false }).count
//        let closedItems = fetchItems().filter({ $0.isComplete }).count
//
//        if openItems == 0 && closedItems > 0 { return true }
//        else { return false }
//    }
    
//    func section() -> Int {
//        if fetchItems().filter({ $0.isComplete }).count > 0 {
//            return 3
//        }
//        else {
//            return 2
//        }
//    }
    
//    func showCompletedButton() -> Int {
//        if fetchItems().filter({ $0.isComplete }).count > 0 { return 1 }
//        else { return 0 }
//    }
//
//    func getCompletedItemsCount() -> Int {
//        let completedCount = fetchItems().filter({ $0.isComplete }).count
//        return completedCount
//    }
    
    
    //ITEMS CONTROLLER METHODS
//    func setSections() -> [ControllerSectionInfo] {
//        if let fetchedSections = itemsFetchedResultsController?.sections?.map({ $0.name }) {
//            let sectionValueIndexes = fetchedSections.map({ ($0, fetchedSections.firstIndex(of: $0)) })
//            let sections = sectionValueIndexes.map({ ControllerSectionInfo(section: ItemsSection(rawValue: $0.0)!, fetchedIndex: $0.1, fetchController: itemsFetchedResultsController!) })
//            return sections
//        }
//        return []
//    }
//
//    func fetchItems() -> [Items] {
//        let items = itemsFetchedResultsController?.fetchedObjects as? [Items]
//        return items.map({ $0 }) ?? []
//    }
//
//    func itemsControllerItemAtIndexPath(indexPath: IndexPath, sections: [ControllerSectionInfo]) -> Items? {//old itemsAtIndexPath
//        let sectionInfo = sections[indexPath.section]
//        if let section = sectionInfo.fetchedIndex {
//            let indexPath = IndexPath(row: indexPath.row, section: section)
//            let itemAtIndexPath = itemsFetchedResultsController?.object(at: indexPath) as! Items
//            return itemAtIndexPath
//        }
//        return nil
//    }

//    func reloadData() {
//        try! itemsFetchedResultsController?.performFetch()
//        sections = setSections()
//    }
    
//    func displayedIndexPathForFetchedIndexPath(_ fetchedIndexPath: IndexPath, sections: [ControllerSectionInfo])  -> IndexPath? {
//        for (sectionIndex, sectionInfo) in sections.enumerated() {
//            if sectionInfo.fetchedIndex == fetchedIndexPath.section {
//                return IndexPath(row: fetchedIndexPath.row, section: sectionIndex)
//            }
//        }
//        return nil
//    }
}//


