
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
    private lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.setEmptyViewData(message: .emptyList, icon: UIImage(systemName: "hand.thumbsup")!)
        return view
    }()
    
    
    //MARK: - Initializers
    init(viewController: UIViewController, tableView: UITableView, delegate: UITableViewDelegate, traitCollection: UITraitCollection) {
        self.viewController = viewController
        self.tableView = tableView
        self.tableViewDelegate = delegate
        self.traitCollection = traitCollection
        
        super.init()
        
        registerTableViewCells()
        configureListsController()
        listsFetchedResultsController?.delegate = self
        layoutEmptyView()
    }
    
    func layoutEmptyView() {
        viewController.view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK: - TableView Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        else {
            guard let number = getObjectsAtSection(section: section, frcSection: 0) else {
                return 0
            }
            tableView.handleEmptyView(isEmpty: true, view: emptyView)
            return number
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addListCell = TextFieldCell(style: .default, reuseIdentifier: TableViewCellIDs.ListTextCellID.rawValue)
        addListCell.configure(placeholder: .Title, delegate: self)
        
        if indexPath.section == 0 {
            return addListCell
        }
        else if indexPath.section == 1 {
            let listCell: ListTitleCell = tableView.dequeueReusableCell(for: indexPath)
            if let list = getListAtIndexPath(indexPath: indexPath), let title = list.title, let items = list.items?.allObjects as? [Items] {
                let openCount = items.filter({ $0.isComplete == false }).count
                listCell.configure(listTitle: title, itemsCount: openCount)
            }
            return listCell
        }
        return addListCell
    }
 
    //MARK: - Helpers
    func registerTableViewCells() {
        tableView.registerCell(cellClass: ListTitleCell.self)
        tableView.registerCell(cellClass: TextFieldCell.self)
    }
    
}//

//MARK: - UITextField Delegate
extension MainListsDataSource: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let count = getListsCount()
        let title = textField.text
        ValidateTextField.shared.validateAndSave(viewController,
                                                 textField: textField,
                                                 title: title,
                                                 item: nil,
                                                 list: nil,
                                                 order: count)
        textField.text = ""
        textField.resignFirstResponder()
        
        return true
    }
}

//MARK: - FetchedResultsController Delegate (Lists)
extension MainListsDataSource: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
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
                if let title = managedObject.title, let items = managedObject.items?.allObjects as? [Items] {
                    let openCount = items.filter({ $0.isComplete == false }).count
                    insertedTitleCell.configure(listTitle: title, itemsCount: openCount)
                }
            }
            tableView.reloadRows(at: [frcIndex], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else {
                fatalError("MainViewController = Indexpath on Delete is NIL")
            }
            let tableViewSection = IndexPath(row: indexPath.row, section: 1)
            tableView.deleteRows(at: [tableViewSection], with: .fade)
            
        case .move:
            guard let destinationIndexPath = newIndexPath, let originIndexPath = indexPath else {
                fatalError("MainViewController = Error Moving Row")
            }
            tableView.deleteRows(at: [originIndexPath], with: .fade)
            tableView.insertRows(at: [destinationIndexPath], with: .fade)
            
        @unknown default: print("Default")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
