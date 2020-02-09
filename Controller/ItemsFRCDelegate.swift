//
//  ItemsFRCDelegate.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TasksFramework

class ItemsFetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    fileprivate var sectionsBeingAdded: [Int] = []
    fileprivate var sectionsBeingRemoved: [Int] = []
    fileprivate unowned let tableView: UITableView!
    
    
    open var onUpdate: ((_ cell: UITableViewCell, _ object: AnyObject) -> Void)?
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sectionsBeingAdded = []
        sectionsBeingRemoved = []
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            let sectionsToInsert = handleSectionsInserted(controller: controller, sectionIndex: sectionIndex)
            tableView.insertSections(sectionsToInsert, with: .fade)
            
        case .delete:
            let sectionsToDelete = handleSectionsDeleted(controller: controller, sectionIndex: sectionIndex)
            tableView.deleteSections(sectionsToDelete, with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
                }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                onUpdate?(cell, anObject as AnyObject)
            }
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                if !sectionsBeingAdded.contains(newIndexPath.section) && !sectionsBeingRemoved.contains(indexPath.section) {
                    tableView.moveRow(at: indexPath, to: newIndexPath)
                    print("ItemsFetchedResultsControllerDel - Moving From: Section: \(indexPath.section), Row: \(indexPath.row), TO Section: \(newIndexPath.section), Row: \(newIndexPath.row)")
                }
                else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print("ItemsFetchedResultsControllerDel - Deleting Row At Section: \(indexPath.section), Row: \(indexPath.row)")
                    tableView.insertRows(at: [newIndexPath], with: .fade)
                    print("ItemsFetchedResultsControllerDel - Inserting Row At Section: \(newIndexPath.section), Row: \(newIndexPath.row)")
                }
            }
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}

extension ItemsFetchedResultsControllerDelegate {
    
    func returnTableViewIndexPath(from frcIndexPath: IndexPath) -> IndexPath {
        
        switch frcIndexPath.section {
        case 0: return [1, frcIndexPath.row]
        case 1: return [3,frcIndexPath.row]
        case 2: return [2, frcIndexPath.row]
            //If there are 0 open items, and section 2 becomes closed
        default: return [1,frcIndexPath.row]
        }
    }
    
    func handleSectionsInserted(controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndex: Int) -> IndexSet {
        let items = allItems(for: controller)
        let openItems = openItemsCount(for: controller)
        let closedItems = closedItemsCount(for: controller)
        let completedButtonIndex = 2
        
        if sectionIndex == 1 {
            if addingFirstItemToNewList(openItems: openItems, closedItems: closedItems, allItems: items) || movingFirstItemFromClosedToEmptyOpenSection(open: openItems, closed: closedItems, items: items) {
                //Adding first item to new list. Adding tableview section 0 -- creating list.
                return [sectionIndex]
            }
            else if closingOnlyOpenItemInList(open: openItems, closed: closedItems, items: items) {
                //Adding First and only list item to closed.
                return [completedButtonIndex, sectionIndex]
            }
        }
        if sectionIndex == 3 {
            //Adding First Item from Open to Closed
            print("SECTIONS CHANGED: \(sectionIndex) && \(completedButtonIndex)")
            return [completedButtonIndex, sectionIndex]
        }
        return [sectionIndex]
    }
    
    func handleSectionsDeleted(controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndex: Int) -> IndexSet {
        let openItems = openItemsCount(for: controller)
        let closedItems = closedItemsCount(for: controller)
        let items = allItems(for: controller)
        let completedButtonIndex = 2
        
        if sectionIndex == 1 {
            if closingOnlyOpenItemInList(open: openItems, closed: closedItems, items: items) {
                return [sectionIndex]
            }
            else if movingLastCompletedItemToOpen(open: openItems, closed: closedItems, allItems: items) {
                //Hit when only item in list is moved from closed to open -- section index is 1 here not 3
                return [completedButtonIndex, sectionIndex]
            }
        }
        else if sectionIndex == 3 {
            //This gets hit when moving last item from closed to open
            if movingLastCompletedItemToOpen(open: openItems, closed: closedItems, allItems: items) {
                return [completedButtonIndex, sectionIndex]
            }
        }
        return [sectionIndex]
    }
    
    //MARK: - Helpers
    func openItemsCount(for controller: NSFetchedResultsController<NSFetchRequestResult>) -> Int {
        if let openCount = (controller.fetchedObjects as? [Items])?.filter({ $0.isComplete == false }).count {
            return openCount
        }
        else {
            return 0
        }
    }
    
    func closedItemsCount(for controller: NSFetchedResultsController<NSFetchRequestResult>) -> Int {
        if let closedCount = (controller.fetchedObjects as? [Items])?.filter({ $0.isComplete }).count {
            return closedCount
        }
        else { return 0 }
    }
    
    func allItems(for controller: NSFetchedResultsController<NSFetchRequestResult>) -> Int {
        if let allItems = (controller.fetchedObjects as? [Items]) {
            let allItemsCount = allItems.count
            return allItemsCount
        }
        else { return 0 }
    }
    
    func addingFirstItemToNewList(openItems: Int, closedItems: Int, allItems: Int) -> Bool {
        if (openItems == 1 && closedItems == 0) && allItems == 1 {
            //We are adding first list item = all items == 1 and there are no closed items.
            return true
        }
        else {
            return false
        }
    }
    
    func closingOnlyOpenItemInList(open: Int, closed: Int, items: Int) -> Bool {
        if open == 0 && closed == 1 {
            return true
        }
        else {
            return false
        }
    }
    
    func movingFirstItemFromClosedToEmptyOpenSection(open: Int, closed: Int, items: Int) -> Bool {
        if open == 1 && closed >= 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func movingLastCompletedItemToOpen(open: Int, closed: Int, allItems: Int) -> Bool {
        if open > 0  && closed == 0 {
            return true
        }
        else {
            return false
        }
    }
    
}//
