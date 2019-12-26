//
//  AddItemsViewController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TasksFramework

class AddItemsToListViewController: UIViewController, CoreDataManagerViewController, CanReadFromDatabase {
    var listsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var completedItemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    //MARK: - Properties
    var listTitle: List?
    var coreDataManager: CoreDataManager?
    var modelObjectType: ModelObjectType?
    var id: String?
    var isCompletedShowing: Bool?
    
    fileprivate lazy var tableView: UITableView = {
        let addItemsTableView = UITableView(frame: view.frame, style: .plain)
        addItemsTableView.delegate = self
        addItemsTableView.dataSource = self
        addItemsTableView.separatorStyle = .singleLine
        addItemsTableView.tableFooterView = UIView()
        addItemsTableView.register(TextFieldCell.self, forCellReuseIdentifier: ItemsCellID.ItemTextFieldCellID.rawValue)
        addItemsTableView.register(ItemAddedCell.self, forCellReuseIdentifier: ItemsCellID.OpenItemCell.rawValue)
        addItemsTableView.register(CompletedButtonCell.self, forCellReuseIdentifier: ItemsCellID.CompletedButtonCell.rawValue)
        addItemsTableView.register(CompletedItemsCell.self, forCellReuseIdentifier: ItemsCellID.CompletedItemsCell.rawValue)
        return addItemsTableView
    }()
    
    fileprivate lazy var fetchedResultsControllerDelegate: ItemsFetchedResultsControllerDelegate = {
        let delegate = ItemsFetchedResultsControllerDelegate(tableView: self.tableView)
        return delegate
    }()
    
    fileprivate lazy var itemsController: ItemsController = {
        let id = String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)
        let controller = ItemsController(id: id!)
            return controller
        
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        isCompletedShowing = false
        configureController()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.handleThemeChange()
        NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
    }
    
    func configureController() {
        itemsController = ItemsController(id: String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)!)
        itemsController.delegate = fetchedResultsControllerDelegate
        let id = String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)
        let pred = NSPredicate(format: "titleID == %@", id!)
        configureReadItemsController(predicate: pred)
    }
    
    //MARK: - Functions
    func setUpView() {
        view.addSubview(tableView)
        navigationController?.navigationBar.topItem?.title = "\(listTitle?.title ?? "")"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    }
    
    //MARK: - Button Functions
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        dismiss(animated: true, completion: nil)
    }
    
}//CLASS

//MARK: - TABLEVIEW DATASOURCE
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
    
    func checkIfItemsAreAllComplete(items: [Items]) -> Bool {
        let openItemsCount = items.filter({ $0.isComplete == false }).count
        let closedItemsCount = items.filter({ $0.isComplete }).count
        
        if openItemsCount == 0 && closedItemsCount > 0 {
            return true
        }
        else { return false }
    }
    
    //MARK: - TABLEVIEW SECTIONS
    func getNumberOfRowsForSection(section: Int) -> Int {
        //Handle Only Completed Items, No Open To-do's
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
    
    func getSectionsCount() -> Int? {
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
    
    func handleOnlyCompletedItemsRowsInSection(section: Int, items: [Items]) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return completedItemsFor(section: section)
        default: return 4
        }
    }
    
    func openItemsFor(section: ItemsSection) -> Int {
        //See if there's problems here, fetchItems().count isn't in completed items for section
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
    
    func completedItemsFor(section: Int) -> Int {
        var items = 0
        if itemsController.fetchItems().count > 0 {
            if let sections = itemsController.sections {
                //FRC Section will be 0  here, only closed Items when this gets called.
                items = sections[0].numberOfObjects
            }
        }
        return items
    }
    
    func itemsSectionCount() -> Int {
        if let sections = itemsController.sections {
            return sections.count
        }
        return 1
    }
     //MARK: - TABLEVIEW ROWS
    func populateNumberOfRowsInTableSection(indexPath: IndexPath) -> UITableViewCell {
        if itemsController.allItemsAreComplete() { return populateOnlyCompletedRowsInTable(tvIndexPath: indexPath) }
            if indexPath.section == 0 {
                let textFieldCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.ItemTextFieldCellID.rawValue, for: indexPath) as! TextFieldCell
                configureTextFieldCell(textFieldCell, tableIndexPath: indexPath)
                return textFieldCell
            }
            if indexPath.section == 1 {
                let openItemsCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.OpenItemCell.rawValue, for: indexPath) as! ItemAddedCell
                let activeFRCSection = Int(ItemsSection.ToDo.rawValue)!
                configureItemsCells(openItemsCell, tableIndexPath: indexPath, frcSection: activeFRCSection)
                return openItemsCell
            }
            if indexPath.section == 2 {
                let completedButtonCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.CompletedButtonCell.rawValue, for: indexPath) as! CompletedButtonCell
                configureCompletedButtonCell(completedButtonCell, tableIndexPath: indexPath)
                return completedButtonCell
            }
            else {
                let completedItemsCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.CompletedItemsCell.rawValue, for: indexPath) as! CompletedItemsCell
                if isCompletedShowing! {
                    let completedItemsSection = Int(ItemsSection.Completed.rawValue)!
                    configureItemsCells(completedItemsCell, tableIndexPath: indexPath, frcSection: completedItemsSection)
                    return completedItemsCell
                }
            }
        return UITableViewCell()
    }
        
    func populateOnlyCompletedRowsInTable(tvIndexPath: IndexPath) -> UITableViewCell {
        switch tvIndexPath.section {
        case 0:
            let textFieldCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.ItemTextFieldCellID.rawValue, for: tvIndexPath) as! TextFieldCell
            configureTextFieldCell(textFieldCell, tableIndexPath: tvIndexPath)
            return textFieldCell
        case 1:
            let completedButtonCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.CompletedButtonCell.rawValue, for: tvIndexPath) as! CompletedButtonCell
            configureCompletedButtonCell(completedButtonCell, tableIndexPath: tvIndexPath)
            return completedButtonCell
        case 2:
            let completedItemsCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.CompletedItemsCell.rawValue, for: tvIndexPath) as! CompletedItemsCell
            if isCompletedShowing! {
                let completedItemsSection = 0
                configureItemsCells(completedItemsCell, tableIndexPath: tvIndexPath, frcSection: completedItemsSection)
                return completedItemsCell
            } else {
                return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    //MARK: - Configuring Cells
    func configureTextFieldCell(_ cell: TextFieldCell, tableIndexPath: IndexPath) {
        cell.cellTextField.setTextFieldPlaceholder(placeHolderText: .Item)
        cell.backgroundColor = Colors.tasksRed
        cell.cellTextField.delegate = self
    }
    
    func configureCompletedButtonCell(_ cell: CompletedButtonCell, tableIndexPath: IndexPath) {
        cell.whenShowCompletedTapped {
            [unowned self] in
            self.isCompletedShowing = !self.isCompletedShowing!
            self.tableView.reloadData()
        }
        if self.isCompletedShowing! { cell.showCompletedButton.setTitle(CompletedButtonTitle.notHidden.rawValue, for: .normal) }
        else { cell.showCompletedButton.setTitle(CompletedButtonTitle.isHidden.rawValue, for: .normal) }
    }
    
    func configureItemsCells(_ itemsCell: ItemsBaseCell, tableIndexPath: IndexPath, frcSection: Int) {
        let frcIndexPath = IndexPath(row: tableIndexPath.row, section: frcSection)
        if let sections = itemsController.sections, let itemAtIndex = itemsController.itemsControllerItemAtIndexPath(indexPath: frcIndexPath, sections: sections) {
            let itemFlaggedStatus = itemAtIndex.isFlagged
            itemsCell.itemLabel.text = itemAtIndex.item
            itemsCell.flaggedButton.setImage(itemAtIndex.isFlagged ? FlagImage.FilledFlag : FlagImage.EmptyFlag, for: .normal)
            itemsCell.flaggedButton.tintColor = itemFlaggedStatus ? Colors.tasksYellow : Colors.tasksRed
            
            itemsCell.whenFlaggedButtonTapped {
                [unowned self] in
                itemAtIndex.isFlagged = !itemFlaggedStatus
                CoreDataManager.shared.setItemFavorite(item: itemAtIndex, status: !itemFlaggedStatus)
                itemsCell.flaggedButton.setImage(itemAtIndex.isFlagged ? FlagImage.EmptyFlag : FlagImage.FilledFlag, for: .normal)
                itemsCell.flaggedButton.tintColor = itemAtIndex.isFlagged ? Colors.tasksRed : Colors.tasksYellow
                self.tableView.reloadData()
            }
            itemsCell.whenCompletedButtonTapped {
                [unowned self] in
                CoreDataManager.shared.setCompletedStatus(item: itemAtIndex)
                if self.itemsController.getCompletedItemsCount() == 0 { self.isCompletedShowing = false }
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: TABLEVIEW DELEGATE METHODS
extension AddItemsToListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 { return 15 }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15))
        footerView.backgroundColor = Colors.tasksRed
        if section == 0 { return footerView }
        else { return nil }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 15 }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15))
        headerView.backgroundColor = Colors.tasksRed
        if section == 0 { return headerView }
        else { return nil }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {//My To-Do's
            let frcSection = Int(ItemsSection.ToDo.rawValue)!
            let fetchedIndexPath = IndexPath(row: indexPath.row, section: frcSection)
            if let sections = itemsController.sections {
                let item = itemsController.itemsControllerItemAtIndexPath(indexPath: fetchedIndexPath, sections: sections)
                let editItemController = EditItemViewController()
                editItemController.items = item
                self.navigationController?.pushViewController(editItemController, animated: true)
            }
        }
    }
}

extension AddItemsToListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            if let itemAdded = textField.text {
                guard let listTitle = listTitle else { fatalError("NO Title - TextFieldShouldReturn in Additemsvc") }
                //let items = listTitle.items?.allObjects as? [Items]
                let items = [listTitle.items]
                let order = items.count 
                ValidateTextField.shared.validateAndSave(self, textField: textField, title: nil, item: itemAdded, list: listTitle, order: order)
                textField.text = ""
                textField.resignFirstResponder()
                tableView.reloadData()
            }
        }
        return true
    }
}

/*
 //
 //  AddItemsViewController.swift
 //  Tasks
 //
 //  Created by Dylan  on 12/3/19.
 //  Copyright © 2019 Dylan . All rights reserved.
 //

 import Foundation
 import UIKit
 import CoreData
 import TasksFramework

 class AddItemsToListViewController: UIViewController, CoreDataManagerViewController, CanReadFromDatabase {
     var listsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
     var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
     var completedItemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
     
     //MARK: - Properties
     var listTitle: List?
     var coreDataManager: CoreDataManager?
     var modelObjectType: ModelObjectType?
     var id: String?
     var isCompletedShowing: Bool?
     
     fileprivate lazy var tableView: UITableView = {
         let addItemsTableView = UITableView(frame: view.frame, style: .plain)
         addItemsTableView.delegate = self
         addItemsTableView.dataSource = self
         addItemsTableView.separatorStyle = .singleLine
         addItemsTableView.tableFooterView = UIView()
         addItemsTableView.register(TextFieldCell.self, forCellReuseIdentifier: ItemsCellID.ItemTextFieldCellID.rawValue)
         addItemsTableView.register(ItemAddedCell.self, forCellReuseIdentifier: ItemsCellID.OpenItemCell.rawValue)
         addItemsTableView.register(CompletedButtonCell.self, forCellReuseIdentifier: ItemsCellID.CompletedButtonCell.rawValue)
         addItemsTableView.register(CompletedItemsCell.self, forCellReuseIdentifier: ItemsCellID.CompletedItemsCell.rawValue)
         return addItemsTableView
     }()
     
     fileprivate lazy var fetchedResultsControllerDelegate: ItemsFetchedResultsControllerDelegate = {
         let delegate = ItemsFetchedResultsControllerDelegate(tableView: self.tableView)
         return delegate
     }()
     var itemsController: ItemsController?
     
     
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setUpView()
         isCompletedShowing = false
         //setFRCDelegate()
         configureController()
     }
     
     override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
         view.handleThemeChange()
         NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
     }
     
     func configureController() {
         setFRCDelegate()
         let id = String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)
         let pred = NSPredicate(format: "titleID == %@", id!)
         configureReadItemsController(predicate: pred)
     }
     
     func setFRCDelegate() {
         itemsController = ItemsController(id: String(data: (listTitle?.recordID)!, encoding: String.Encoding.utf8)!)
         itemsController?.delegate = fetchedResultsControllerDelegate
     }
     //MARK: - Functions
     func setUpView() {
         view.addSubview(tableView)
         navigationController?.navigationBar.topItem?.title = "\(listTitle?.title ?? "")"
         navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
         navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
     }
     
     //MARK: - Button Functions
     @objc func handleCancel() {
         dismiss(animated: true, completion: nil)
     }
     
     @objc func handleDone() {
         dismiss(animated: true, completion: nil)
     }
     
 }//CLASS

 //MARK: - TABLEVIEW DATASOURCE
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
     
     func checkIfItemsAreAllComplete(items: [Items]) -> Bool {
         let openItemsCount = items.filter({ $0.isComplete == false }).count
         let closedItemsCount = items.filter({ $0.isComplete }).count
         
         if openItemsCount == 0 && closedItemsCount > 0 {
             return true
         }
         else { return false }
     }
     
     //MARK: - TABLEVIEW SECTIONS
     func getNumberOfRowsForSection(section: Int) -> Int {
         //Handle Only Completed Items, No Open To-do's
 //        guard let itemsController = itemsController else { return 0 }
 //        let fetchedItems = itemsController.fetchItems()
 //        if checkIfItemsAreAllComplete(items: fetchedItems) { return handleOnlyCompletedItemsRowsInSection(section: section, items: fetchedItems) } //if allItemsAreComplete { return handleOnlyCompleted... }
         if allItemsAreComplete() { return handleOnlyCompletedItemsRowsInSection(section: section, items: fetchItems()) }
         else {
             switch section {
             case 0: return 1
             case 1:
                 if fetchItems().count > 0  && Int(ItemsSection.ToDo.rawValue) != nil && itemsController != nil {//??
                     if let section = Int(ItemsSection.ToDo.rawValue), let controller = itemsController, let openSections = controller.sections {
                         return openSections[section].numberOfObjects
                     }
                 }
             case 2: return showCompletedButton()
                 //showCompletedButton
 //                if fetchedItems.filter({ $0.isComplete }).count > 0 { return 1 }
 //                else { return 0 }
             case 3: return completedItemsForSection(section: Int(ItemsSection.Completed.rawValue)!)
                 //completedItemsForSection
 //                guard let resultsControllerSection = Int(ItemsSection.Completed.rawValue) else { return 0 }
 //                return itemsController.sections[resultsControllerSection].numberOfObjects
             default: return 0
             }
         }
 }
     
     func getSectionsCount() -> Int? {
         if allItemsAreComplete() { return 3 }
 //        guard let itemsController = itemsController else { return 1 }
 //        if checkIfItemsAreAllComplete(items: itemsController.fetchItems()) {
 //            return 3
 //        }
         else {
             switch returnItemsSectionsCount() {
             case 0: return 1
             case 1: return section()
             case 2: return 4
             default: return 1
             }
         }
         
         //        else {
         //            switch itemsController.sections.count {//returnSectionsCount Function
         //            case 0: return 1
         //            case 1: //if allItemsAreComplete { return 3 }
         //                if itemsController.fetchItems().filter({ $0.isComplete }).count > 0 { return 3 }
         //                else { return 2 }
         //            case 2: return 4
         //            default: return 1
         //            }
         //        }
         
     }
     
     func handleOnlyCompletedItemsRowsInSection(section: Int, items: [Items]) -> Int {
         //guard let itemsController = itemsController else { return 1 }
         switch section {
         case 0: return 1
         case 1: return 1
         case 2: if fetchItems().count > 0 {
             return itemsController?.sections[0].numberOfObjects }
             completedItemsForSection(section: 0)
             //completedItemsForSection
 //            let fetchedResultsControllerIndex = 0
 //            return itemsController.sections[fetchedResultsControllerIndex].numberOfObjects
         default: return 4
         }
     }
     
      //MARK: - TABLEVIEW ROWS
     func populateNumberOfRowsInTableSection(indexPath: IndexPath) -> UITableViewCell {
         if allItemsAreComplete() { return populateOnlyCompletedRowsInTable(tvIndexPath: indexPath) }
             if indexPath.section == 0 {
                 let textFieldCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.ItemTextFieldCellID.rawValue, for: indexPath) as! TextFieldCell
                 configureTextFieldCell(textFieldCell, tableIndexPath: indexPath)
                 return textFieldCell
             }
             if indexPath.section == 1 {
                 let openItemsCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.OpenItemCell.rawValue, for: indexPath) as! ItemAddedCell
                 let activeFRCSection = Int(ItemsSection.ToDo.rawValue)!
                 configureItemsCells(openItemsCell, tableIndexPath: indexPath, frcSection: activeFRCSection)
                 return openItemsCell
             }
             if indexPath.section == 2 {
                 let completedButtonCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.CompletedButtonCell.rawValue, for: indexPath) as! CompletedButtonCell
                 configureCompletedButtonCell(completedButtonCell, tableIndexPath: indexPath)
                 return completedButtonCell
             }
             else {
                 let completedItemsCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.CompletedItemsCell.rawValue, for: indexPath) as! CompletedItemsCell
                 if isCompletedShowing! {
                     let completedItemsSection = Int(ItemsSection.Completed.rawValue)!
                     configureItemsCells(completedItemsCell, tableIndexPath: indexPath, frcSection: completedItemsSection)
                     return completedItemsCell
                 }
             }
         return UITableViewCell()
     }
         
     func populateOnlyCompletedRowsInTable(tvIndexPath: IndexPath) -> UITableViewCell {
         switch tvIndexPath.section {
         case 0:
             let textFieldCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.ItemTextFieldCellID.rawValue, for: tvIndexPath) as! TextFieldCell
             configureTextFieldCell(textFieldCell, tableIndexPath: tvIndexPath)
             return textFieldCell
         case 1:
             let completedButtonCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.CompletedButtonCell.rawValue, for: tvIndexPath) as! CompletedButtonCell
             configureCompletedButtonCell(completedButtonCell, tableIndexPath: tvIndexPath)
             return completedButtonCell
         case 2:
             let completedItemsCell = tableView.dequeueReusableCell(withIdentifier: ItemsCellID.CompletedItemsCell.rawValue, for: tvIndexPath) as! CompletedItemsCell
             if isCompletedShowing! {
                 let completedItemsSection = 0
                 configureItemsCells(completedItemsCell, tableIndexPath: tvIndexPath, frcSection: completedItemsSection)
                 return completedItemsCell
             } else {
                 return UITableViewCell()
             }
         default: return UITableViewCell()
         }
     }
     
     //MARK: - Configuring Cells
     func configureTextFieldCell(_ cell: TextFieldCell, tableIndexPath: IndexPath) {
         cell.cellTextField.setTextFieldPlaceholder(placeHolderText: .Item)
         cell.backgroundColor = Colors.tasksRed
         cell.cellTextField.delegate = self
     }
     
     func configureCompletedButtonCell(_ cell: CompletedButtonCell, tableIndexPath: IndexPath) {
         cell.whenShowCompletedTapped {
             [unowned self] in
             self.isCompletedShowing = !self.isCompletedShowing!
             self.tableView.reloadData()
         }
         if self.isCompletedShowing! { cell.showCompletedButton.setTitle(CompletedButtonTitle.notHidden.rawValue, for: .normal) }
         else { cell.showCompletedButton.setTitle(CompletedButtonTitle.isHidden.rawValue, for: .normal) }
     }
     
     func configureItemsCells(_ itemsCell: ItemsBaseCell, tableIndexPath: IndexPath, frcSection: Int) {
         let frcIndexPath = IndexPath(row: tableIndexPath.row, section: frcSection)
         if let itemAtIndex = itemsControllerItemAtIndexPath(indexPath: frcIndexPath) {
             let itemFlaggedStatus = itemAtIndex.isFlagged
             itemsCell.itemLabel.text = itemAtIndex.item
             itemsCell.flaggedButton.setImage(itemAtIndex.isFlagged ? FlagImage.FilledFlag : FlagImage.EmptyFlag, for: .normal)
             itemsCell.flaggedButton.tintColor = itemFlaggedStatus ? Colors.tasksYellow : Colors.tasksRed
             
             itemsCell.whenFlaggedButtonTapped {
                 [unowned self] in
                 itemAtIndex.isFlagged = !itemFlaggedStatus
                 CoreDataManager.shared.setItemFavorite(item: itemAtIndex, status: !itemFlaggedStatus)
                 itemsCell.flaggedButton.setImage(itemAtIndex.isFlagged ? FlagImage.EmptyFlag : FlagImage.FilledFlag, for: .normal)
                 itemsCell.flaggedButton.tintColor = itemAtIndex.isFlagged ? Colors.tasksRed : Colors.tasksYellow
                 self.tableView.reloadData()
             }
             itemsCell.whenCompletedButtonTapped {
                 [unowned self] in
                 CoreDataManager.shared.setCompletedStatus(item: itemAtIndex)
                 if self.getCompletedItemsCount() == 0 { self.isCompletedShowing = false }
                 self.tableView.reloadData()
             }
         }
     }
 }

 //MARK: TABLEVIEW DELEGATE METHODS
 extension AddItemsToListViewController: UITableViewDelegate {
     
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         if section == 0 { return 15 }
         else { return 0 }
     }
     
     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
         let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15))
         footerView.backgroundColor = Colors.tasksRed
         if section == 0 { return footerView }
         else { return nil }
     }
     
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         if section == 0 { return 15 }
         else { return 0 }
     }
     
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15))
         headerView.backgroundColor = Colors.tasksRed
         if section == 0 { return headerView }
         else { return nil }
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if indexPath.section == 1 {//My To-Do's
             let frcSection = Int(ItemsSection.ToDo.rawValue)!
             let fetchedIndexPath = IndexPath(row: indexPath.row, section: frcSection)
             //guard let itemsController = itemsController else { return }
             let item = itemsControllerItemAtIndexPath(indexPath: fetchedIndexPath)
             let editItemController = EditItemViewController()
             editItemController.items = item
             self.navigationController?.pushViewController(editItemController, animated: true)
         }
     }
 }

 extension AddItemsToListViewController: UITextFieldDelegate {
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         if textField.tag == 0 {
             if let itemAdded = textField.text {
                 guard let listTitle = listTitle else { fatalError("NO Title - TextFieldShouldReturn in Additemsvc") }
                 //let items = listTitle.items?.allObjects as? [Items]
                 let items = [listTitle.items]
                 let order = items.count
                 ValidateTextField.shared.validateAndSave(self, textField: textField, title: nil, item: itemAdded, list: listTitle, order: order)
                 textField.text = ""
                 textField.resignFirstResponder()
                 tableView.reloadData()
             }
         }
         return true
     }
 }


 */
