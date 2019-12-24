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
        let allItems = (controller.fetchedObjects as? [Items])!.count
        let open = (controller.fetchedObjects as? [Items])?.filter({ $0.isComplete == false })
        let closed = (controller.fetchedObjects as? [Items])?.filter({ $0.isComplete })
        
        let closingOnlyOpenItem = open?.count == 0 && closed?.count == 1
        let addingFirstItemToClosed = allItems == 1 && open!.count >= 1 && closed?.count == 1
        let movingFirstClosedItemToOpen = open?.count == 1 && closed!.count >= 0
        
        let completedButtonIndex = 2
        
        if sectionIndex == 1 {
            //Adding Section 1 when First item is added to a list
            if addingFirstItemToClosed { return [sectionIndex] }
            //Closing only Open Item, Adding Sections 2 & 3 respectively that will become sections 1 & 2
            if closingOnlyOpenItem {
                print("CLOSING ONLY OPEN ITEM -- INSERTING SECTION(S): \(completedButtonIndex), & \(sectionIndex) ")
                return [completedButtonIndex, sectionIndex]
            }
            //Moving First closed item to open (0 open)
            if movingFirstClosedItemToOpen {
                print("MOVING FIRST CLOSED ITEM TO OPEN -- INSERTING SECTION(S): \(completedButtonIndex), & \(sectionIndex) ")
                return [sectionIndex]
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
        let open = (controller.fetchedObjects as? [Items])?.filter({ $0.isComplete == false })
        let closed = (controller.fetchedObjects as? [Items])?.filter({ $0.isComplete })
        let closingOnlyOpenItem = open?.count == 0 && closed?.count == 1
        let movingLastClosedItemToOpen = open!.count > 0 && closed?.count == 0
        
        let completedButtonIndex = 2
        
        if sectionIndex == 1 {
            if closingOnlyOpenItem {
                return [sectionIndex]
            }
            else if movingLastClosedItemToOpen {
                return [completedButtonIndex, sectionIndex]
            }
        }
        else if sectionIndex == 3 {
            if movingLastClosedItemToOpen {
                //Delete Button Section & Closed Items Section
                return [completedButtonIndex, sectionIndex]
            }
        }
        return [sectionIndex]
    }
    
    
}//
