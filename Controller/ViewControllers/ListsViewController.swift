//
//  ListsViewController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TasksFramework

class ListsViewController: UIViewController, CanWriteToDatabase {
   
    //MARK: Properties
    lazy var dataSource: MainListsDataSource = {
        let mainDataSource = MainListsDataSource(viewController: self, tableView: self.tableView, delegate: self, traitCollection: traitCollection)
        return mainDataSource
    }()
    var lists = [List]()
    private var tableView: UITableView!
   
    
   //MARK: - Life Cycle
    override func viewDidLoad() {
        super .viewDidLoad()
        view.backgroundColor = .systemBackground
//        CoreDataManager.shared.batchDeleteCoreData(entityName: .Items)
        setUpView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.handleThemeChange()
        tableViewBackground(tableView: tableView)
    }
    
 //MARK: - Create TableView & Set Up View
    func setUpView() {
        let listTableView = UITableView(frame: view.frame, style: .plain)
        tableView = listTableView
        view.addSubview(tableView)
        listTableView.dataSource = dataSource
        listTableView.delegate = self
        listTableView.separatorStyle = .singleLine
        listTableView.tableFooterView = UIView()
        
        navigationItem.createNavigationBar(title: "My Lists", leftItem: nil, rightItem: nil)
    }
    
    func tableViewBackground(tableView: UITableView) {
        tableView.handleTableViewForIOS13()
        NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
    }
    
    func handleSegueToListItems(indexPath: IndexPath) {
//        let tabBarController = TasksTabBarController()
        let fetchedResutsControllerIndexPath = IndexPath(row: indexPath.row, section: 0)
        guard let listAtIndexPath = dataSource.listsFetchedResultsController?.object(at: fetchedResutsControllerIndexPath) as? List else {
            Alerts.showNormalAlert(self, title: "Error", message: "Error Fetching List")
            return
        }
        
        let controller = AddItemsToListViewController()
        controller.listTitle = listAtIndexPath
        navigationController?.pushViewController(controller, animated: true)
        //present(tabBarController, animated: true, completion: nil)
    }
    
}//
extension ListsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSegueToListItems(indexPath: indexPath)
    }
    
    //MARK: - Header & Footer:
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
        //Only 1 section in this view, returning cell height I want
    }
    
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 15
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15))
//        view.backgroundColor = .lightGray
//        return view
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 10
//        }
//        else {
//            return 0
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
//        view.backgroundColor = .lightGray
//        return view
//    }
    
    
    //MARK: TableView Swipe Actions:
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 { return nil }
        let fetchedIndex = IndexPath(row: indexPath.row, section: 0)
        guard let list = dataSource.listsFetchedResultsController?.object(at: fetchedIndex) as? List else { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action: UIContextualAction, view: UIView, completionHandler: (Bool) -> Void) in
            Alerts.showAlert(self, message: "Deleting \(list.title!) will delete all data associated with this list. Are you sure you want to delete?") {
                print("Deleting list: \(list.title ?? "No List To Delete")")
                self.deleteFromCoreData(object: list)
                let allLists = self.dataSource.listsFetchedResultsController?.fetchedObjects as! [List]
                self.updateOrderAfterDelete(objects: allLists, entity: .List)
            }
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (shareAction: UIContextualAction, view: UIView, completionHandler: (Bool) -> Void) in
            //TO-TO: Open Share Extensionn
            print("Open Share Extension")
            
            if let items = list.items?.allObjects as? [Items] {
                OpenShareExtension(items: items)
            }
            completionHandler(true)
            
        }
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        shareAction.backgroundColor = .blue
        deleteAction.image = UIImage(systemName: "trash")
        
        let actions = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return actions
    }
}

