//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.

import Foundation
import CoreData
import TasksFramework

/*
    This class is the fetchedResultsController used by 'AddItemsViewController'. This class is called when objects are inserted/updated/changed in that VC. This gets the info from the Tableview and Datasource
    then uses the 'ItemsFetchedResultsControllerDelegate' file to pass that data along.
    * The delegate of this file is ItemsFetchedResultsControllerDelegate
    * This class is responsible for handling changes in Sections (When Items are moved between open/closed sections). It uses the ControllerSectionInfo file to maintain the correct number of sections in the table.
 */
final class ItemsController: NSObject, CanReadFromDatabase {
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
    ///This method provides a list of fetched items from the FetchedResultsController.
    /// - Returns: An array of Items values or an empty array if there are no vaues yet.
    func fetchItems() -> [Items] {
        let items = itemsController.fetchedObjects as? [Items]
        return items?.map{ $0 } ?? []
    }
    
    /// Returns the item at the indexPath passed into this method.
    /// - Parameters:
    ///   - indexPath: Item text to display in the TableView Cell.
    ///   - sections: Takes array of ControllerSectionInfo.
    /// - Returns: The item at the specified index path.
    func itemsControllerItemAtIndexPath(indexPath: IndexPath, sections: [ControllerSectionInfo]) -> Items? {
        let sectionInfo = sections[indexPath.section]
        if let section = sectionInfo.fetchedIndex {
            let indexPath = IndexPath(row: indexPath.row, section: section)
            let itemAtIndexPath = itemsFetchedResultsController?.object(at: indexPath) as! Items
            return itemAtIndexPath
        }
        return nil
    }
    
    // MARK: - TableView Sections Methods. Obtain Items For Section for Open & Closed Items
    
    ///Returns the number of objects contained in the fetchedResultsController for Open & Closed Items
    /// - Parameters:
    ///     - section: ItemsSection value
    /// - Returns: Int value for number of items in section
    func openItemsFor(section: ItemsSection) -> Int {
        let itemsCount = fetchItems().count
        
        if itemsCount > 0 {
            if let sections = sections {
                switch section {
                case .ToDo:
                    let openItemsSec = Int(section.rawValue)!
                    return sections[openItemsSec].numberOfObjects
                case .Completed:
                    let completedItemSec = Int(section.rawValue)!
                    return sections[completedItemSec].numberOfObjects
                }
            }
        }
       return 0
    }
    
    ///Returns the number of completed items for the specified section.
    /// - Parameters:
    ///     - section: UITableView section value.
    /// - Returns: Int value for number of completed items in the section.
    func completedItemsFor(section: Int) -> Int {
        var items = 0
        let itemsCount = fetchItems().count
        if itemsCount > 0 {
            if let sections = sections {
                items = sections[0].numberOfObjects
            }
        }
        return items
    }
    
    //SECTIONS COUNT
    /// Uses the itemsController sections property to return the correctnumber of UITableView sections to display.
    /// - Returns: Int value containing the number of sections for the TableView.
    func getSectionsCount() -> Int? {
        let sectionsCount = sections?.count ?? 1
        if allItemsAreComplete() { return 3 }
        else {
            switch sectionsCount {
            case 0: return 1
            case 1: return numberOfSectionsBasedOnItemStatus()
            case 2: return 4
            default: return 1
            }
        }
    }
    
    // NUMBER OF ROWSIN SEC
    /// Gets the number of rows for section value passed in.
    /// - Parameters:
    ///     - section: UITableView section passed in
    /// - Returns: Int value with number of rows for the section.
    func getNumberOfRowsIn(section: Int) -> Int {
        if allItemsAreComplete() { return handleOnlyCompletedItemsRowsIn(section: section) }
        else {
            switch section {
            case 0: return 1
            case 1: return openItemsFor(section: .ToDo)
            case 2: return showCompletedButton()
            case 3: return openItemsFor(section: .Completed)
            default:  return 1
            }
        }
    }
    
    ///Handles a situation where the list only contains closed items.
    /// - Parameters:
    ///     - section: Section passed in by the UITableView.
    /// - Returns: Int value representing the number of completed rows in section.
    func handleOnlyCompletedItemsRowsIn(section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return completedItemsFor(section: section)
        default: return 4
        }
    }
    
    
    ///Checks if all items in a specified list are complete.
    /// - Returns: Boolean value displaying the status of items.
    func allItemsAreComplete() -> Bool {
        let openItems = fetchItems().filter({ $0.isComplete == false }).count
        let closedItems = fetchItems().filter({ $0.isComplete }).count
        
        if openItems == 0 && closedItems > 0 { return true }
        else { return false }
    }
    
    ///Checks whether or not the Show Completed button should be displayed on screen. If there are any completed items in a list this button will be shown.
    /// - Returns: This method returns an Int value 1 if the button should be shown and 0 if it should not.
    func showCompletedButton() -> Int {
        let closedCount = fetchItems().filter({ $0.isComplete }).count
        if closedCount > 0 { return 1 }
        else { return 0 }
    }
    
    ///Returns a number of sections for UITableView based on the status of items. If there are more than 1 completed item returns 3 else returns 2.
    /// - Returns: Int value representing number of UITableView sections. If completetd items > 0 returns 3 sections else returns 2 sections..
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
            
        case .move:
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
    ///Since the FetchedResultsController sections and TableView sections don't match this method converts the sections received from the FRC to provide the correct number of sections for the TableView. There will always be one section in the TableView which contains the text field view.
    /// - Description:
    ///         - If the fetchedResultsController produces 0 for sections, we'll return 1 tableView section (open items only). If the fetchedResultsController produces 1 for section (2 sections) we'll produce 3 for the tableView sections since our tableView will have one section for open items, one section for closed items, one section for the 'showCompleted' button as well as section 0 showing the textField.
    /// - Parameters:
    ///     - controllerIndex: fetchedResultsController's section that's passed in.
    /// - Returns: The converted Section Number as Int
    func getTableViewSection(from controllerIndex: Int) -> Int {
        switch controllerIndex {
        case 0:     return 1
        case 1:     return 3
        case 2:     return 1
        default:    return 1
        }
    }
    
    ///Updates the indexPath provided to return the indexPath with an updated section value.
    /// - Description:
    ///         - Takes in the indexPath provided from the Controller, updates the section to the appropriate tableView section so the delegate functions don't crash the tableView.
    /// - Parameters:
    ///     - controllerIndexPath: IndexPath provided
    /// - Returns: IndexPath with the updated section value.
    func updateTableViewIndexPath(from controllerIndexPath: IndexPath) -> IndexPath {
        switch controllerIndexPath.section {
        case 0: return IndexPath(row: controllerIndexPath.row, section: 1)
        case 1: return IndexPath(row: controllerIndexPath.row, section: 3)
        case 2: return IndexPath(row: controllerIndexPath.row, section: 1)
        default: return IndexPath(row: controllerIndexPath.row, section: 1)
        }
    }
    
    /// Handles moving an item within a list between sections when the item being moved is not the first or last item in a list.
    /// - Parameters:
    ///   - controller: FetchedResultsController that sent the message.
    ///   - indexPath: IndexPath of changed object (nil for insertions).
    ///   - newIndexPath: Destination indexPath of object for insertions or moved items (nil for deletions).
    ///   - object: Object in controller's fetched results thats changed.
    ///   - type: Type of change. -> NSFetchedResultsControllerChangeType.
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
    
    /// Handles two possibilities: 1. moving the first item into a new section, either first item from open to closed OR first item from closed to open. 2. With a total of only 2 items in a list this handles when the first item is moved from open to closed or closed to open.
    /// - Parameters:
    ///   - controller: FetchedResultsController that sent the message.
    ///   - indexPath: IndexPath of changed object (nil for insertions).
    ///   - newIndexPath: Destination indexPath of object for insertions or moved items (nil for deletions).
    ///   - object: Object in controller's fetched results thats changed.
    ///   - type: Type of change. -> NSFetchedResultsControllerChangeType.
    private func handleMovingFirstItemIntoNewSection(in controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath, newIndexPath: IndexPath, object: Any, type: NSFetchedResultsChangeType) {
        /* This method has two scenarios it handles. First is there are more than 2 items total in the list, and moving the first item into a new section (open -> closed OR closed -> open)
            When there are two items total && both are open || both are closed:
                * When first open goes to closed -> moving from TV section 1 to section 3
                * When first closed goes to open this will hit the else statement below.
        */
        
        let open = getOpenItemsCount()
        let closed = getClosedItemsCount()
        openItemsBeforeChange = determineOpenItems()
        
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
    
    /// When an item is updated; Moved from one section to another when that item is not the first or last item in a section.
    /// - Parameters:
    ///   - controller: FetchedResultsController that sent the message.
    ///   - indexPath: IndexPath of changed object (nil for insertions).
    ///   - newIndexPath: Destination indexPath of object for insertions or moved items (nil for deletions).
    ///   - object: Object in controller's fetched results thats changed.
    ///   - type: Type of change. -> NSFetchedResultsControllerChangeType.
    private func handleTaskItemMoved(in controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath, newIndexPath: IndexPath, object: Any, type: NSFetchedResultsChangeType) {
        print("ItemsController - MOVING ITEM, NOT FIRST OR LAST")
        let tableIndexPath = updateTableViewIndexPath(from: indexPath)
        let tableNewIndexPath = updateTableViewIndexPath(from: newIndexPath)
        print("ItemsController - Moving item from \(tableIndexPath.section), row: \(tableIndexPath.row) to Newsection: \(tableNewIndexPath.section), Newrow: \(tableNewIndexPath.row)")
        delegate?.controller?(controller, didChange: object, at: tableIndexPath, for: type, newIndexPath: tableNewIndexPath)
    }
    
    /// Method handles moving the last item out of a section. If moving the last completed item to open, this method will remove the completed items section along with the show completed button tableview section. If moving the last item from open to closed it will remove the open section
    /// add the showCompleted button section along with the closed section.
    /// - Parameters:
    ///   - controller: FetchedResultsController that sent the message.
    ///   - indexPath: IndexPath of changed object (nil for insertions).
    ///   - newIndexPath: Destination indexPath of object for insertions or moved items (nil for deletions).
    ///   - object: Object in controller's fetched results thats changed.
    ///   - type: Type of change. -> NSFetchedResultsControllerChangeType.
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
    
    ///
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
    
    /// This method uses 'filter' to filter all items to show only items where the isComplete property is false.
    /// - Returns: Int value containing the number of items that are open.
    private func getOpenItemsCount() -> Int {
        return fetchItems().filter({ $0.isComplete == false }).count
    }
    
    /// This method uses 'filter' to filter list of all items returning only items that have the isComplete property set to 'true'.
    /// - Returns: Int value containing the number of closed items.
    func getClosedItemsCount() -> Int {
        return fetchItems().filter({ $0.isComplete }).count
    }
    
    
}//
