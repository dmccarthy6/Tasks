//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.

import UIKit
import NotificationCenter
import CoreData
import TasksFramework


class TodayWidgetViewController: UIViewController, NCWidgetProviding {
    //MARK: - Properties
    private var widgetMangedContext = CoreDataManager.shared.ckContainerContext
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WidgetCell.self, forCellReuseIdentifier: cellIdentifier)
        return tableView
    }()
    private lazy var reminderItemsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntity.Items.rawValue)
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "reminderDate", ascending: true)]
//        fetchReq.predicate = DatesPredicate.reminderDateIsTodayPredicate()
        fetchReq.predicate = NSPredicate(value: true)
        
        let controller = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: widgetMangedContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
        }
        catch let error as NSError {
            print("Error Fetching All Data: \(error.localizedDescription)")
        }
        return controller
    }()
    private lazy var emptyDataView: EmptyWidgetView = {
        let view = EmptyWidgetView()
        return view
    }()
    private let cellIdentifier = "widgetCell"
    private var initialCount: Int?
    
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        print("Context: \(widgetMangedContext), Controller: \(reminderItemsController)")
        layoutViews()
    }
 
    
    /// Widget functions. Called when the data is updated to create the new snapshot.
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        do {
            try reminderItemsController.performFetch()
            print("NUMBER OF ITEMS FETCHED: \(fetchAllItems().count)")
            completionHandler(.newData)
        }
        catch let error as NSError {
            print("WIDGET FAILED TO FETCH: -- \(error.localizedDescription)")
            completionHandler(.failed)
        }
    }
    
    /// Sets size of the widget in the Today View. Max height set to 300
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            self.preferredContentSize = maxSize
        case .expanded:
             self.preferredContentSize = CGSize(width: maxSize.width, height: 300)
        @unknown default: ()
        }
    }
    
    //MARK: - Helpers
    /// Add the tableView to the view, layout the tableView and set the preferredContentSize.
    private func layoutViews() {
        self.preferredContentSize.height = 200
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    /// Show Empty Data View if the dataSource is empty (if there are no items with reminders set).
    /// - Parameters:
    ///     - reminderItems: Takes an Int
    private func handleEmptyDataSource(reminderItems: Int) {
        if reminderItems == 0 {
            emptyDataView.configureEmptyView(text: .noRemindersSetToday)
            tableView.separatorStyle = .none
            tableView.backgroundView = emptyDataView
        }
        else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
    }
    
    /// Configure reminderItemsController when the WidgetViewController is loaded.
    private func configureController() {
        do {
            try reminderItemsController.performFetch()
            let items = reminderItemsController.fetchedObjects as! [Items]
            print(items)
        }
        catch let error as NSError {
            print("Error Initially Fetching CD: \(error.localizedDescription)")
        }
    }
    
    /// Fetch all Items that have reminders.
    ///  - Returns: Array of Items values that have reminders set.
    private func fetchAllItems() -> [Items] {
        if let items = reminderItemsController.fetchedObjects as? [Items] {
            return items
        }
        else { return [] }
    }
    
    /// Obtain the Item at the current index,
    /// - Parameters:
    ///      - indexPath: The Current TableView indexPath.
    /// - Returns: The current item at the specified indexPath.
    private func reminderItemAtIndex(indexPath: IndexPath) -> Items {
        return reminderItemsController.object(at: indexPath) as! Items
    }
    
}

//MARK: - UITableView Data Source Methods
extension TodayWidgetViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchAllItems().count
        handleEmptyDataSource(reminderItems: count)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WidgetCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WidgetCell

        let itemsArray = fetchAllItems()
        let itemForRow = itemsArray[indexPath.row]
        
        cell.configureWidgetCellText(text: itemForRow.item ?? "", isFlagged: itemForRow.isFlagged, isComplete: itemForRow.isComplete)
        
        cell.toggleCompletedFunction {
            cell.widgetCompleteTask(isComplete: itemForRow.isComplete, item: itemForRow)
        }
        cell.toggleFlaggedFunction {
            cell.widgetFlaggedTapped(isFavorite: itemForRow.isFlagged, item: itemForRow)
        }
        return cell
    }
}

//MARK: - UITableView Delegate Methods
extension TodayWidgetViewController: UITableViewDelegate {
    
    /// Delegate Methods ---> Open Tasks App From Today Widget
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let context = self.extensionContext else { return }
        let itemAtIndex = reminderItemAtIndex(indexPath: indexPath)
        OpenTasks.openListItems(in: context, item: itemAtIndex)
    }
}

//MARK: - FetchedResultsController Delegate Methods
extension TodayWidgetViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("Widget Delegate -- Insert Item")
            guard let newIndexPath = newIndexPath else {
                return
            }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .update:
            if let indexPath = indexPath, let managedObject = anObject as? Items, let item = managedObject.item {
                if let reminderItemCell = tableView.cellForRow(at: indexPath) as? WidgetCell {
                    reminderItemCell.configureWidgetCellText(text: item, isFlagged: managedObject.isFlagged, isComplete: managedObject.isComplete)
                }
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
            
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
            
        @unknown default:()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
