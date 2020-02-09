//
//  ItemsController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import CoreData
import TasksFramework

class ItemsController: NSObject, CanReadFromDatabase {
    var listsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var completedItemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var delegate: NSFetchedResultsControllerDelegate?
    fileprivate var oldSectionsDuringFetchUpdate: [ControllerSectionInfo] = []
    var sections: [ControllerSectionInfo]?
    var id: String
    fileprivate lazy var itemsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let itemsForListTitlePredicate = NSPredicate(format: "titleID == %@", self.id)
        let controller = ItemsFetchedResultsController(managedObjectContext: managedObjectContext, predicate: itemsForListTitlePredicate)
        
        let controllerToReturn = controller.configureItemsController()
        itemsFetchedResultsController = controller.configureItemsController()
        itemsFetchedResultsController!.delegate = self
        return itemsFetchedResultsController!
    }()
    private var openItemsBeforeChange: Int?
    
    //MARK: - Initializers
    init(id: String) {
        self.id = id
        super.init()
        sections = setSections()
        openItemsBeforeChange = determineOpenItems()
    }
    
    //MARK: - Helpers
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
    
    func numberOfSectionsBasedOnItemStatus() -> Int {
        if fetchItems().filter({ $0.isComplete }).count > 0 {
            return 3
        }
        else { return 2 }
    }
    
    //MARK: - Private Functions
    fileprivate func setSections() -> [ControllerSectionInfo]? {
        guard let fetchedSections = itemsController.sections?.map({ $0.name }) else { return [] }
        let sectionValuesIndexes = fetchedSections.map({ ($0, fetchedSections.firstIndex(of: $0)) })
        let sections = sectionValuesIndexes.map({ ControllerSectionInfo(section: ItemsSection(rawValue: $0.0)!, fetchedIndex: $0.1, fetchController: itemsController) })
        return sections
    }
    
    private func determineOpenItems() -> Int? {
        guard let openItems = itemsController.fetchedObjects as? [Items] else { return 0 }
        print("OpenItemsCount: \(openItems.filter({ $0.isComplete == false }).count)")
        return openItems.filter({ $0.isComplete == false }).count
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
            let indexPathToUse = updateTableViewIndexPath(from: newIndexPath)
            delegate?.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: indexPathToUse)
            
        case .update:
            let item = anObject as! Items
            let displayedOldIndexPath = indexPath.flatMap{ displayedIndexPathForFetchedIndexPath($0, sections: oldSectionsDuringFetchUpdate) }
            let displayedNewIndexPath = indexPath.flatMap{ displayedIndexPathForFetchedIndexPath($0, sections: sections ?? []) }
            delegate?.controller?(controller, didChange: item, at: displayedOldIndexPath, for: type, newIndexPath: displayedNewIndexPath)
            
        case .move://Tap Complete button this hits
            if let indexPath = indexPath, let newIndexPath = newIndexPath, let anObject = anObject as? Items {
                handleMovingListItems(in: controller, indexPath: indexPath, newIndexPath: newIndexPath, object: anObject, type: type)
            }
        case .delete:
            if let indexPath = indexPath {
                delegate?.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
            }
        @unknown default: ()
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
    
    /*
     
     */
    func handleMovingListItems(in controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath, newIndexPath: IndexPath, object: Any, type: NSFetchedResultsChangeType) {
        if (getOpenItemsCount() == 0 && getClosedItemsCount() >= 1) || (getClosedItemsCount() == 0 && getOpenItemsCount() >= 1) {
            handleMovingLastItemOutOfSection(in: controller, indexPath: indexPath, newIndexPath: newIndexPath, object: object, type: type)
        }
        else if (getOpenItemsCount() == 1 && sectionsAreNotEqual()) || (getClosedItemsCount() == 1 && sectionsAreNotEqual()) {
            handleMovingFirstItemIntoNewSection(in: controller, indexPath: indexPath, newIndexPath: newIndexPath, object: object, type: type)
        }
        else if getOpenItemsCount() >= 1 || getClosedItemsCount() >= 1 && !sectionsAreNotEqual(){
            handleTaskItemMoved(in: controller, indexPath: indexPath, newIndexPath: newIndexPath, object: object, type: type)
        }
    }
    
    private func handleMovingFirstItemIntoNewSection(in controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath, newIndexPath: IndexPath, object: Any, type: NSFetchedResultsChangeType) {
        /* This method has two scenarios it handles. First is there are more than 2 items total in the list, and moving the first item into a new section (open -> closed OR closed -> open)
            When there are two items total && both are open || both are closed:
                * When first open goes to closed -> moving from TV section 1 to section 3
                * When first closed goes to open this will hit the else statement below.
        */
        
        let open = getOpenItemsCount()
        let closed = getClosedItemsCount()
        
        if open >= 1 && closed == 1 {
            if openItemsBeforeChange == 0 {
                //First closed item to Open when there are only 2 items and both are closed.
                openItemsBeforeChange = determineOpenItems()
                let currentIndexPath = IndexPath(row: indexPath.row, section: 2)
                let destinationIndexPath = IndexPath(row: indexPath.row, section: 1)
                delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
            }
            else {
                //First open item to closed when there are only 2 items (at this moment 1 is open, 1 is closed)
                let currentIndexPath = IndexPath(row: indexPath.row, section: 1)
                let destinationIndexPath = IndexPath(row: newIndexPath.row, section: 2)
                delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
            }
        }
        else if open > 1 && closed == 1 {
            //Moving the first item from open (irregardless of open.count) to closed.
            let currentIndexPath = IndexPath(row: indexPath.row, section: 1)
            let destinationIndexPath = IndexPath(row: newIndexPath.row, section: 2)
            delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
        }
        else if closed >= 1 && open == 1 {
            //Moving first item into opened if there are greater than 1 item in closed.
            print("ItemsController - FIRST ITEM TO OPEN SECTION FROM CLOSED")
            let currentIndexPath = IndexPath(row: indexPath.row, section: 2)
            let destinationIndexPath = IndexPath(row: newIndexPath.row, section: 1)
            delegate?.controller?(controller, didChange: object, at: currentIndexPath, for: type, newIndexPath: destinationIndexPath)
        }
    }
    
    /*
     This method handles items moving between sections when it's not the first or last item in either section.
     */
    private func handleTaskItemMoved(in controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath, newIndexPath: IndexPath, object: Any, type: NSFetchedResultsChangeType) {
        //Not the first or last item moved -- from either section.
        print("ItemsController - MOVING ITEM, NOT FIRST OR LAST")
        let tableIndexPath = updateTableViewIndexPath(from: indexPath)
        let tableNewIndexPath = updateTableViewIndexPath(from: newIndexPath)
        print("ItemsController - Moving item from \(tableIndexPath.section), row: \(tableIndexPath.row) to Newsection: \(tableNewIndexPath.section), Newrow: \(tableNewIndexPath.row)")
        delegate?.controller?(controller, didChange: object, at: tableIndexPath, for: type, newIndexPath: tableNewIndexPath)
    }
    
    /*
     This method handles moving the last item out of a section (deleting the sections the items were removed from & handling either adding or deleting the 'showCompleted' button based on the item counts.
     */
    private func handleMovingLastItemOutOfSection(in controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath, newIndexPath: IndexPath, object: Any, type: NSFetchedResultsChangeType) {
        let open = getOpenItemsCount()
        let closed = getClosedItemsCount()
        
        if open == 0 {
            openItemsBeforeChange = determineOpenItems()
            print("ItemsController - MOVING LAST ITEM FROM OPEN TO CLOSED")
            let currentIndex = updateTableViewIndexPath(from: indexPath)
            let destinationIndexPath = IndexPath(row: newIndexPath.row, section: 2)
            print("ItemsController - Moving last item from open to closed; From: \(currentIndex.section), \(currentIndex.row) to \(destinationIndexPath.section), \(destinationIndexPath.row)")
            delegate?.controller?(controller, didChange: object, at: currentIndex, for: type, newIndexPath: destinationIndexPath)
        }
        if closed == 0 {
            print("ItemsController - MOVING LAST ITEM FROM CLOSED TO OPEN")
            let currentIndex = updateTableViewIndexPath(from: indexPath)
            let destinationIndexPath = IndexPath(row: newIndexPath.row, section: 1)
            print("ItemsController - Moving last item from closed to open; From: \(currentIndex.section), \(currentIndex.row) to \(destinationIndexPath.section), \(destinationIndexPath.row)")
            delegate?.controller?(controller, didChange: object, at: currentIndex, for: type, newIndexPath: destinationIndexPath)
        }
    }
    
    private func sectionsAreNotEqual() -> Bool {
        if let sections = sections {
            if oldSectionsDuringFetchUpdate.count != sections.count {
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    private func getOpenItemsCount() -> Int {
        return fetchItems().filter({ $0.isComplete == false }).count
    }
    
    func getClosedItemsCount() -> Int {
        return fetchItems().filter({ $0.isComplete }).count
    }
    
    
}//
