//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TasksFramework

class ListsViewController: UIViewController, CanWriteToDatabase, CanReadFromDatabase {
    
    //MARK: Properties
    var listsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var completedItemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    lazy private var tableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.registerCell(cellClass: ListTitleCell.self)
        tableView.registerCell(cellClass: TextFieldCell.self)
        return tableView
    }()
    lazy private var emptyView: EmptyView = {
        let emptyView = EmptyView()
        return emptyView
    }()
    private var lists = [List]()
    
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super .viewDidLoad()
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.handleThemeChange()
        tableViewBackground(tableView: tableView)
    }
    
    //MARK: - Helper Functions
    private func setUpView() {
        view.addSubview(tableView)
        tableView.setFullScreenTableViewConstraints(in: view)
        navigationItem.createNavigationBar(title: "Lists", leftItem: nil, rightItem: nil)
        configureListsController()
        listsFetchedResultsController?.delegate = self
    }
    private func tableViewBackground(tableView: UITableView) {
        tableView.handleTableViewForIOS13()
        NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
    }
    
    private func handleSegueToListItems(indexPath: IndexPath) {
        let fetchedResutsControllerIndexPath = IndexPath(row: indexPath.row, section: 0)
        guard let listAtIndexPath = listsFetchedResultsController?.object(at: fetchedResutsControllerIndexPath) as? List else {
            return
        }
        let controller = AddItemsToListViewController()
        controller.listTitle = listAtIndexPath
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func handleEmptyDataSource(number: Int) {
        if number == 0 {
            emptyView.setEmptyViewData(message: .emptyList)
            tableView.backgroundView = emptyView
        }
        else { tableView.backgroundView = nil }
    }
}

//MARK: - UITableView Data Source Methods
extension ListsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        else {
            guard let numberOfRows = getObjectsAtSection(section: section, frcSection: 0) else {
                return 0
            }
            handleEmptyDataSource(number: numberOfRows)
            return numberOfRows
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textFieldCell = TextFieldCell(style: .default, reuseIdentifier: TableViewCellIDs.ListTextCellID.rawValue)
        textFieldCell.configure(placeholder: .Title, delegate: self)
        
        if indexPath.section == 0 { return textFieldCell }
        else if indexPath.section == 1 {
            let listAddedCell: ListTitleCell = tableView.dequeueReusableCell(for: indexPath)
            if let list = getListAtIndexPath(indexPath: indexPath), let title = list.title, let items = list.items?.allObjects as? [Items] {
                let openCount = items.filter({ $0.isComplete == false }).count
                listAddedCell.configure(listTitle: title, itemsCount: openCount)
            }
            return listAddedCell
        }
        return textFieldCell
    }
}

//MARK - UITableView Delegate Methods
extension ListsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        else {
            handleSegueToListItems(indexPath: indexPath)
        }
    }
    
    //MARK: TableView Swipe Actions:
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 { return nil }
        let fetchedIndex = IndexPath(row: indexPath.row, section: 0)
        guard let list = listsFetchedResultsController?.object(at: fetchedIndex) as? List else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action: UIContextualAction, view: UIView, completionHandler: (Bool) -> Void) in
            Alerts.deleteAlert(self, view: view, message: .deleteList) {
                self.deleteFromCoreData(object: list)
                let allLists = self.listsFetchedResultsController?.fetchedObjects as! [List]
                self.updateOrderAfterDelete(objects: allLists, entity: .List)
            }
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (shareAction: UIContextualAction, view: UIView, completionHandler: (Bool) -> Void) in
            if let items = list.items?.allObjects as? [Items] {
                Alerts.shareListActionSheet(self, items: items, popoverView: view)
            }
            completionHandler(true)
        }
        shareAction.image = SystemImages.Share!
        shareAction.backgroundColor = .systemBlue
        deleteAction.image = SystemImages.DeleteTrashCan!
        
        let actions = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return actions
    }
}

//MARK: - UITextField Delegate Methods
extension ListsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let count = getListsCount()
        let title = textField.text
        ValidateTextField.shared.validateAndSave(self, textField: textField, title: title, item: nil, list: nil, order: count)
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Core Data NSFetchedResultsController Delegate Methods
extension ListsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("ListsViewController = FetchedResultsControllerDelegate - Insert Hit")
            guard let newIndexPath = newIndexPath else {
                print("Fell Through")
                return
            }
            let frcIndexPath = IndexPath(row: newIndexPath.row, section: 1)
            tableView.insertRows(at: [frcIndexPath], with: .fade)
            
        case .update:
            print("ListsViewController = FetchedResultsControllerDelegate - Update Hit")
            guard let indexPath = indexPath, let managedObject = anObject as? List else {
                return
            }
            let frcIndexPath = IndexPath(row: indexPath.row, section: 1)
            
            //If this update gets triggered from editing a list title:
            if let editTitleCell = tableView.cellForRow(at: frcIndexPath) as? EditItemCell {
                editTitleCell.configure(text: managedObject.title!, delegate: nil)
            }
            //If this update is triggered from
            if let insertedTitleCell = tableView.cellForRow(at: frcIndexPath) as? ListTitleCell {
                if let title = managedObject.title, let items = managedObject.items?.allObjects as? [Items] {
                    let openCount = items.filter({ $0.isComplete == false }).count
                    insertedTitleCell.configure(listTitle: title, itemsCount: openCount)
                }
            }
            tableView.reloadRows(at: [frcIndexPath], with: .automatic)
        
        case .move:
            guard let destinationIndexPath = newIndexPath, let originIndexPath = indexPath else {
                return
            }
            tableView.deleteRows(at: [originIndexPath], with: .fade)
            tableView.insertRows(at: [destinationIndexPath], with: .fade)
            
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            let tableViewSection = IndexPath(row: indexPath.row, section: 1)
            tableView.deleteRows(at: [tableViewSection], with: .fade)
            
        @unknown default: ()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
