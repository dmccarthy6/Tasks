//
//  ListsDataSource.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MainListsDataSource: NSObject, UITableViewDataSource, CanReadFromDatabase {
    var listsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var completedItemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    

    private var viewController: UIViewController
    private var tableView: UITableView
    private var listTitle: String?
    private var tableViewDelegate: UITableViewDelegate
    var traitCollection: UITraitCollection
    
    
    init(viewController: UIViewController, tableView: UITableView, delegate: UITableViewDelegate, traitCollection: UITraitCollection) {
        self.viewController = viewController
        self.tableView = tableView
        self.tableViewDelegate = delegate
        self.traitCollection = traitCollection
        
        super.init()
        
        registerTableViewCells()
        configureListsController()
        listsFetchedResultsController?.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        else {
            guard let number = getObjectsAtSection(section: section, frcSection: 0) else {
                fatalError("ERROR")
            }
            return number
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addListCell = TextFieldCell(style: .default, reuseIdentifier: ListTableCellID.ListTextCellID.rawValue)
        addListCell.configure(placeholder: .Title, delegate: self, backgroundColor: .systemGray)
        
        if indexPath.section == 0 {
            //addListCell.backgroundColor = .systemGray3
            return addListCell
        }
        else if indexPath.section == 1 {
            let listCell: ListTitleCell = tableView.dequeueReusableCell(for: indexPath)
            if let list = getListAtIndexPath(indexPath: indexPath) {
            //Fetch Core Data, if any:
            listCell.configure(listTitle: list.title!)
            }
            return listCell
        }
        
        return addListCell
    }
 
    func registerTableViewCells() {
        tableView.registerCell(cellClass: ListTitleCell.self)
        tableView.registerCell(cellClass: TextFieldCell.self)
    }
    
}//

extension MainListsDataSource: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let count = getListsCount()
        let title = textField.text
        ValidateTextField.shared.validateAndSave(viewController, textField: textField, title: title, item: nil, list: nil, order: count)
        textField.text = ""
        textField.resignFirstResponder()
        
        return true
    }
}

extension MainListsDataSource: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
            
        case .insert:
            print("MainVCData - FetchedResultsControllerDelegate - INSERT HIT")
            guard let newIndexPath = newIndexPath else {
                fatalError("IndexPath Error - FRC MainVC .Insert")
            }
            let frcIndexPath = IndexPath(row: newIndexPath.row, section: 1)
            tableView.insertRows(at: [frcIndexPath], with: .fade)
            
        case .update:
            print("MainVCData - FetchedResultsControllerDelegate - UPDATE HIT")
            guard let indexPath = indexPath,
                let managedObject = anObject as? List else {
                    print("Error Updating")
                    return
            }
            let frcIndex = IndexPath(row: indexPath.row, section: 1)
            
            if let editedTitleCell = tableView.cellForRow(at: frcIndex) as? EditItemCell {
                editedTitleCell.configure(text: managedObject.title!, delegate: nil)
            }
            if let insertedTitleCell = tableView.cellForRow(at: frcIndex) as? ListTitleCell {
                print("FRC Section: \(frcIndex.section), FRC Row: \(frcIndex.row) ")
                insertedTitleCell.configure(listTitle: managedObject.title!)
            }
            tableView.reloadRows(at: [frcIndex], with: .automatic)
            
        case .delete:
            print("MainVCData - FetchedResultsControllerDelegate - DELETE HIT")
            guard let indexPath = indexPath else {
                fatalError("MainViewController = Indexpath on Delete is NIL")
            }
            let tableViewSection = IndexPath(row: indexPath.row, section: 1)
            //guard let list = listsFetchedResultsController?.object(at: indexPath) as? List else { return }
            tableView.deleteRows(at: [tableViewSection], with: .fade)
            
        case .move:
            print("MainVCData - Move")
            guard let destinationIndexPath = newIndexPath,
                let originIndexPath = indexPath else {
                    fatalError("MainViewController = Error Moving Row")
            }
            tableView.deleteRows(at: [originIndexPath], with: .fade)
            tableView.insertRows(at: [destinationIndexPath], with: .fade)
            
        @unknown default:
            print("Default")
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

