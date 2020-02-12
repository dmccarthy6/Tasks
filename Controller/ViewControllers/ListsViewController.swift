//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TasksFramework

class ListsViewController: UIViewController, CanWriteToDatabase {
    
    //MARK: Properties
    lazy private var dataSource: MainListsDataSource = {
        let mainDataSource = MainListsDataSource(viewController: self, tableView: self.tableView, delegate: self, traitCollection: traitCollection)
        return mainDataSource
    }()
    lazy private var emptyView: EmptyView = {
        let emptyView = EmptyView()
        return emptyView
    }()
    
    private var lists = [List]()
    private var tableView: UITableView!
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super .viewDidLoad()
        //view.backgroundColor = .systemBackground
    
//        CoreDataManager.shared.batchDeleteCoreData(entityName: .List)
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
    func setUpView() {
        let listsTable = UITableView(frame: .zero, style: .plain)
        tableView = listsTable
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        
        view.addSubview(tableView)
        tableView.setFullScreenTableViewConstraints(in: view)
        navigationItem.createNavigationBar(title: "My Lists", leftItem: nil, rightItem: nil)
    }
    private func tableViewBackground(tableView: UITableView) {
        tableView.handleTableViewForIOS13()
        NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
    }
    
    func handleSegueToListItems(indexPath: IndexPath) {
        let fetchedResutsControllerIndexPath = IndexPath(row: indexPath.row, section: 0)
        guard let listAtIndexPath = dataSource.listsFetchedResultsController?.object(at: fetchedResutsControllerIndexPath) as? List else {
            Alerts.showNormalAlert(self, title: "Error", message: "Error Fetching List")
            return
        }
        
        let controller = AddItemsToListViewController()
        controller.listTitle = listAtIndexPath
        navigationController?.pushViewController(controller, animated: true)
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
        guard let list = dataSource.listsFetchedResultsController?.object(at: fetchedIndex) as? List else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action: UIContextualAction, view: UIView, completionHandler: (Bool) -> Void) in
            Alerts.deleteAlert(self, view: view, message: .deleteList) {
                self.deleteFromCoreData(object: list)
                let allLists = self.dataSource.listsFetchedResultsController?.fetchedObjects as! [List]
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

