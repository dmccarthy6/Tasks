
import UIKit
import CoreData
import TasksFramework

final class AddItemsToListViewController: UIViewController, CanReadFromDatabase, CanWriteToDatabase {
    //MARK: - Properties
    var listsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var completedItemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var listTitle: List?
    var listTitleID: String?
    private var isCompletedShowing: Bool = false
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.registerCell(cellClass: TextFieldCell.self)
        tableView.registerCell(cellClass: ItemAddedCell.self)
        tableView.registerCell(cellClass: CompletedButtonCell.self)
        tableView.registerCell(cellClass: CompletedItemsCell.self)
        return tableView
    }()
    private lazy var fetchedResultsControllerDelegate: ItemsFetchedResultsControllerDelegate = {
        let delegate = ItemsFetchedResultsControllerDelegate(tableView: self.tableView)
        return delegate
    }()
    private lazy var itemsController: ItemsController = {
        guard let idData = listTitle?.recordID, let titleIDFromList = String(data: idData, encoding: String.Encoding.utf8) else {
            let listID = listTitleID ?? ""
            let controller = ItemsController(id: listID)
            return controller
        }
        return ItemsController(id: titleIDFromList)
    }()
    private lazy var emptyDataView: EmptyView = {
        let view = EmptyView()
        return view
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        checkHowViewControllerWasOpened(if: listTitleID != nil ? true : false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.handleThemeChange()
        NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
    }
    
    //MARK: - Helpers
    private func configureController() {
        itemsController = ItemsController(id: String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)!)
        itemsController.delegate = fetchedResultsControllerDelegate
        let id = String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)
        let pred = NSPredicate(format: "titleID == %@", id!)
        configureReadItemsController(predicate: pred)
    }
    
    private func setUpView() {
        view.addSubview(tableView)
        navigationItem.createNavigationBar(title: "\(listTitle?.title ?? "")",
            leftItem: nil,
            rightItem: UIBarButtonItem(image: SystemImages.elipses!, style: .plain, target: self, action: #selector(showEditListActionSheet)))
        tableView.setFullScreenTableViewConstraints(in: view)
    }
    
    /* Checking here how this VC was opened. If by Widget, setting listTitle property by fetching via recordID. Else calling configureController which configures based on list segued in */
    /// Checks how the AddItemsViewController was opened. If it was opened via the Today Widget setting the list, delegate, and reloading data.
    private func checkHowViewControllerWasOpened(if fromWidget: Bool) {
        if fromWidget {
            //Configure FetchedResultsController -- this came from Today Widget need to get and set listTitle here as well.
            if let listTitleID = listTitleID {
                itemsController = configureControllerOpenedByWidget(id: listTitleID)
                itemsController.delegate = fetchedResultsControllerDelegate
                listTitle = itemsController.fetchItems()[0].list
                tableView.reloadData()
            }
        } //Configure FetchedResultsController Normally. Opened via Lists Segue
        else { configureController() }
    }
    
    //MARK: - Button Functions
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func showEditListActionSheet() {
        if let list = listTitle {
            Alerts.editListActionSheet(title: list, popoverBarItem: navigationItem.rightBarButtonItem!)
        }
    }
    
}
//MARK: - UITableView Data Source Methods
extension AddItemsToListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let numberOfSections = itemsController.getSectionsCount() {
            return numberOfSections
        }
        else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsController.getNumberOfRowsIn(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        populateNumberOfRowsInTableSection(indexPath: indexPath)
    }
    
    //MARK: - TableView Helper Functions -- Sections

    /// Gets number of sections from the itemsController 'sections' property.
    /// - Returns: Int value with number of sections
    private func itemsSectionCount() -> Int {
        if let sections = itemsController.sections {
            return sections.count
        }
        return 1
    }
    //MARK: - Tableview Helper Functions -- Rows
    ///Populates the number of rows in the tableView.
    /// - Parameters:
    ///     - indexPath: IndexPath from the tableView
    /// - Returns: UITableViewCell
    private func populateNumberOfRowsInTableSection(indexPath: IndexPath) -> UITableViewCell {
        if itemsController.allItemsAreComplete() { return populateOnlyCompletedRowsInTable(tvIndexPath: indexPath) }
        if indexPath.section == 0 { // Text Field Cell
            let textFieldCell: TextFieldCell = tableView.dequeueReusableCell(for: indexPath)
            textFieldCell.configure(placeholder: .Item, delegate: self)
            return textFieldCell
        }
        if indexPath.section == 1 { // Open Items Cells
            let openItemsCell: ItemAddedCell = tableView.dequeueReusableCell(for: indexPath)
            let frcIndexPath = IndexPath(row: indexPath.row, section: Int(ItemsSection.ToDo.rawValue)!)
            if let sections = itemsController.sections, let itemAtIndex = itemsController.itemsControllerItemAtIndexPath(indexPath: frcIndexPath, sections: sections) {
                openItemsCell.configureCell(item: itemAtIndex)
                openItemsCell.whenFlaggedButtonTapped {
                    openItemsCell.userTappedFlaggedButton(item: itemAtIndex, isFlagged: itemAtIndex.isFlagged, tableView: self.tableView)
                }
                openItemsCell.whenCompletedButtonTapped {
                    openItemsCell.userTappedCompletedButton(item: itemAtIndex)
                }
            }
            return openItemsCell
        }
        if indexPath.section == 2 {//SHOW COMPLETED BUTTON
            let completedButtonCell: CompletedButtonCell = tableView.dequeueReusableCell(for: indexPath)
            completedButtonCell.setCompletedButtonTitleAfterLastCompletedItemRemoved(completedShowing: isCompletedShowing)
            handleShowCompletedTapped(for: completedButtonCell)
            return completedButtonCell
        }
        else if indexPath.section == 3 {//CLOSED ITEMS
            let completedItemsCell: CompletedItemsCell = tableView.dequeueReusableCell(for: indexPath)
            if self.isCompletedShowing {
                let frcIndexPath = IndexPath(row: indexPath.row, section: Int(ItemsSection.Completed.rawValue)!)
                if let sections = itemsController.sections, let closedItemAtIndexPath = itemsController.itemsControllerItemAtIndexPath(indexPath: frcIndexPath, sections: sections) {
                    completedItemsCell.configure(item: closedItemAtIndexPath)
                    completedItemsCell.whenFlaggedButtonTapped {
                        completedItemsCell.userChangedFlagged(item: closedItemAtIndexPath, isFlagged: closedItemAtIndexPath.isFlagged, tableView: self.tableView)
                    }
                    completedItemsCell.whenCompletedButtonTapped {
                        completedItemsCell.userTappedComplete(item: closedItemAtIndexPath)
                    }
                    handleCompletedItemsCompletedButtonTapoedFor(completedCell: completedItemsCell, item: closedItemAtIndexPath)
                }
                return completedItemsCell
            }
        }
        return UITableViewCell()
    }
    
    //If All Items Are Completed; Need to adjust Sections here, FRC will have 1 section '0' and TV will have 3 sections.
    /// Populates the cells in the tableview when all items are closed. Will be called when there are no open items currently.
    /// - Parameters:
    ///     - tvIndexPath: The tableView indexPath passed in
    /// - Returns: A UITableViewCell
    private func populateOnlyCompletedRowsInTable(tvIndexPath: IndexPath) -> UITableViewCell {
        switch tvIndexPath.section {
        case 0:
            let textFieldCell: TextFieldCell = tableView.dequeueReusableCell(for: tvIndexPath)
            textFieldCell.configure(placeholder: .Item, delegate: self)
            return textFieldCell
        case 1: //Completed Button
            let completedButtonCell: CompletedButtonCell = tableView.dequeueReusableCell(for: tvIndexPath)
            self.handleShowCompletedTapped(for: completedButtonCell)
            return completedButtonCell
        case 2:
            let completedItemsCell: CompletedItemsCell = tableView.dequeueReusableCell(for: tvIndexPath)
            if self.isCompletedShowing {
                let frcIndexPath = IndexPath(row: tvIndexPath.row, section: 0)
                if let sections = itemsController.sections, let itemAtIndexPath = itemsController.itemsControllerItemAtIndexPath(indexPath: frcIndexPath,
                                                                                                                                 sections: sections) {
                    completedItemsCell.configure(item: itemAtIndexPath)
                    completedItemsCell.whenFlaggedButtonTapped {
                        completedItemsCell.userChangedFlagged(item: itemAtIndexPath, isFlagged: itemAtIndexPath.isFlagged, tableView: self.tableView)
                    }
                    completedItemsCell.whenCompletedButtonTapped {
                        completedItemsCell.userTappedComplete(item: itemAtIndexPath)
                    }
                   handleCompletedItemsCompletedButtonTapoedFor(completedCell: completedItemsCell, item: itemAtIndexPath)
                }
                return completedItemsCell
            } else {
                return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    //MARK: - Cell Button Helpers - Toggle Show Completed
    ///Handles the operations when user hits the 'showCompleted' button. Changes the button title based on the status and toggles the isCompletedShowing variable.
    /// - Parameters:
    ///     - cell: Completed Button Cell
    private func handleShowCompletedTapped(for cell: CompletedButtonCell) {
        cell.whenShowCompletedTapped { [unowned self] in
            self.isCompletedShowing.toggle()
            self.tableView.reloadData()
            if self.isCompletedShowing {
                cell.createShowCompletedButton(withTitle: .hideCompleted)
            }
            else if !self.isCompletedShowing {
                cell.createShowCompletedButton(withTitle: .showCompleted)
            }
        }
    }
    
    ///Sets the isCompleted variable to false when we move the last item out of the closed section this way when user adds the first item to closed the items won't show unless
    ///they hit the 'showCompleted' button.
    /// - Parameters:
    ///     - completedCell: a Complleted Item cell that the user hit the closed button on
    ///     - item: Item value contained in the cell.
    private func handleCompletedItemsCompletedButtonTapoedFor(completedCell: CompletedItemsCell, item: Items) {
        completedCell.whenCompletedButtonTapped { [unowned self] in
            self.setItemCompletedStatus(item: item)
            if self.itemsController.getClosedItemsCount() == 0 {
                self.isCompletedShowing = false
            }
            self.tableView.reloadData()
        }
    }
    
}

//MARK: UITableView Delegate Methods
extension AddItemsToListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        //Stops selection of the button cell from segueing when all items are closed (if all items are closed, this cell becomes section 1)
        if indexPath.section == 1 && itemsController.allItemsAreComplete() { return }
        if indexPath.section == 1 {
            let frcSection = Int(ItemsSection.ToDo.rawValue)!
            let fetchedIndexPath = IndexPath(row: indexPath.row, section: frcSection)
            if let sections = itemsController.sections {
                let item = self.itemsController.itemsControllerItemAtIndexPath(indexPath: fetchedIndexPath, sections: sections)
                let editItemController = EditItemViewController()
                editItemController.itemBeingEdited = item
                self.navigationController?.pushViewController(editItemController, animated: true)
            }
        }
    }
}
//MARK: - UITextField Delegate Methods
extension AddItemsToListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            if let itemAdded = textField.text {
                if let listTitle = listTitle, let items = listTitle.items?.allObjects as? [Items] {
                    let order = items.count
                    ValidateTextField.shared.validateAndSave(self, textField: textField, title: nil, item: itemAdded, list: listTitle, order: order)
                    textField.text = ""
                    textField.resignFirstResponder()
                }
            }
        }
        return true
    }
}
