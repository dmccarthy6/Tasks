
import UIKit
import CoreData
import TasksFramework


final class AddItemsToListViewController: UIViewController, CanReadFromDatabase, CanWriteToDatabase {
    //MARK: - Properties
    var listsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var completedItemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var listTitle: List?
    private var isCompletedShowing: Bool = false
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 100
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
        let listTitleID = String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)
        let controller = ItemsController(id: listTitleID!)
        return controller
    }()
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureController()
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
        if let numberOfSections = getSectionsCount() {
            return numberOfSections
        }
        else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberOfRowsForSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        populateNumberOfRowsInTableSection(indexPath: indexPath)
    }
    
    //MARK: - TableView Helper Functions -- Sections
    private func checkIfItemsAreAllComplete(items: [Items]) -> Bool {
        let openItemsCount = items.filter({ $0.isComplete == false }).count
        let closedItemsCount = items.filter({ $0.isComplete }).count
        
        if openItemsCount == 0 && closedItemsCount > 0 {
            return true
        }
        else { return false }
    }
    
    private func getNumberOfRowsForSection(section: Int) -> Int {
        //Check if we only have completed items, if so, adjust sections accordingly.
        if itemsController.allItemsAreComplete() { return handleOnlyCompletedItemsRowsInSection(section: section, items: itemsController.fetchItems()) }
        else {
            switch section {
            case 0: return 1
            case 1: return openItemsFor(section: .ToDo)
            case 2: return itemsController.showCompletedButton()
            case 3: return openItemsFor(section: .Completed)
            default: return 0
            }
        }
    }
    
    private func getSectionsCount() -> Int? {
        if itemsController.allItemsAreComplete() { return 3 }
        else {
            switch self.itemsSectionCount() {
            case 0: return 1
            case 1: return itemsController.numberOfSectionsBasedOnItemStatus()
            case 2: return 4
            default: return 1
            }
        }
    }
    
    private func handleOnlyCompletedItemsRowsInSection(section: Int, items: [Items]) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return completedItemsFor(section: section)
        default: return 4
        }
    }
    
    private func openItemsFor(section: ItemsSection) -> Int {
        if itemsController.fetchItems().count > 0 {
            if let sections = itemsController.sections {
                switch section {
                case .ToDo:
                    let todoSection = Int(section.rawValue)
                    return sections[todoSection!].numberOfObjects
                case .Completed:
                    let completedSection = Int(section.rawValue)
                    return sections[completedSection!].numberOfObjects
                }
            }
        }
        return 0
    }
    
    private func completedItemsFor(section: Int) -> Int {
        var items = 0
        if itemsController.fetchItems().count > 0 {
            if let sections = itemsController.sections {
                //FRC Section will be 0  here, only closed Items when this gets called.
                items = sections[0].numberOfObjects
            }
        }
        return items
    }
    
    private func itemsSectionCount() -> Int {
        if let sections = itemsController.sections {
            return sections.count
        }
        return 1
    }
    //MARK: - Tableview Helper Functions -- Rows
    private func populateNumberOfRowsInTableSection(indexPath: IndexPath) -> UITableViewCell {
        if itemsController.allItemsAreComplete() { return populateOnlyCompletedRowsInTable(tvIndexPath: indexPath) }
        if indexPath.section == 0 {
            let textFieldCell: TextFieldCell = tableView.dequeueReusableCell(for: indexPath)
            textFieldCell.configure(placeholder: .Item,
                                    delegate: self)
                                    
            return textFieldCell
        }
        if indexPath.section == 1 {
            let openItemsCell: ItemAddedCell = tableView.dequeueReusableCell(for: indexPath)
            let frcIndexPath = IndexPath(row: indexPath.row, section: Int(ItemsSection.ToDo.rawValue)!)
            if let sections = itemsController.sections, let itemAtIndex = itemsController.itemsControllerItemAtIndexPath(indexPath: frcIndexPath, sections: sections) {
                openItemsCell.configureCell(itemText: itemAtIndex.item!)
                openItemsCell.handleUserTapFlagOrFavoriteButtons(for: itemAtIndex,
                                                                 isFlagged: itemAtIndex.isFlagged,
                                                                 tableView: tableView)
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
                    completedItemsCell.configure(item: closedItemAtIndexPath.item!)
                    completedItemsCell.handleUserTapCompletedOrFavorite(for: closedItemAtIndexPath,
                                                                        isFlagged: closedItemAtIndexPath.isFlagged,
                                                                        tableView: tableView)
                    handleCompletedItemsCompletedButtonTapoedFor(completedCell: completedItemsCell, item: closedItemAtIndexPath)
                }
                return completedItemsCell
            }
        }
        return UITableViewCell()
    }
    
    //If All Items Are Completed; Need to adjust Sections here, FRC will have 1 section '0' and TV will have 3 sections.
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
                    completedItemsCell.configure(item: itemAtIndexPath.item!)
                    completedItemsCell.handleUserTapCompletedOrFavorite(for: itemAtIndexPath,
                                                                        isFlagged: itemAtIndexPath.isFlagged,
                                                                        tableView: tableView)
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
        if indexPath.section == 1 {//My To-Do's
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
