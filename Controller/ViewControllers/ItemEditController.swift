//
//  ItemEditController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import EventKit
import TasksFramework

class EditItemViewController: UIViewController, CoreDataManagerViewController {
    
    //MARK: - Properties
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    var coreDataManager: CoreDataManager?
    var modelObjectType: ModelObjectType?
    var items: Items?
    var alertDatePicker: UIDatePicker?
    let cellHeight: CGFloat = 40
    
    
    //Cell Identifiers
    private let editItemCellID = "EditItemCell"
    private let menuCellID = "MenuCell"
    private let reminderDatePickerID = "ReminderDatePickerCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView()
        
        checkForUpdate()
    }
    
    func checkForUpdate() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            tableView.separatorColor = .white
            tableView.backgroundColor = .systemBackground
        } else {
            tableView.separatorColor = .black
            tableView.backgroundColor = Colors.editItemRed
        }
    }

    //MARK: - Create TableView
    func createTableView() {
        setUpView()
    }

    func setUpView() {
        view.addSubview(tableView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: view.bounds.size.width, height: view.bounds.size.height))
        //Register TableView Cells
        tableView.register(EditItemCell.self, forCellReuseIdentifier: editItemCellID)
        tableView.register(MenuCell.self, forCellReuseIdentifier: menuCellID)
        tableView.register(ReminderDatePickerCell.self, forCellReuseIdentifier: reminderDatePickerID)
        
        if let item = items {
            navigationItem.title = item.item
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    //MARK: - Date Picker Functions
    @objc func reminderDatePickerChanged(sender: UIDatePicker) {
        let stringDate = sender.date.getReminderDateAsString(pickerDate: sender.date)
        let reminderIndexPath = IndexPath(row: 0, section: 1)
        let reminderCell = tableView.cellForRow(at: reminderIndexPath) as! MenuCell
        CoreDataManager.shared.setItemAlert(item: items!, alert: sender.date)
        reminderCell.valueLabel.text = stringDate
    }
    
    func toggleDatePicker(datePicker: UIDatePicker) {
        datePicker.isHidden = !datePicker.isHidden
    }
    
    //MARK: - Setting Due Date To Core Data through Delegate
    func eventAdded(event: EKEvent) {
        guard let items = items else { return }
        let eventDate = event.startDate
        CoreDataManager.shared.setDueDate(item: items, date: eventDate!)
    }
    
    //MARK: - Navigation
    @objc func doneButtonTapped() {
        handleDismiss()
    }
    
    func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.dismiss(animated: true, completion: nil)
        }) { (success) in
            //
        }
    }
    
}//

extension EditItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 { return 4 }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let labelCell = tableView.dequeueReusableCell(withIdentifier: menuCellID, for: IndexPath(row: indexPath.row, section: 1)) as! MenuCell
        let reminderDatePickerCell = ReminderDatePickerCell(style: .default, reuseIdentifier: reminderDatePickerID)
        
        if indexPath.section == 0 {
            let editItemTextFieldCell = EditItemCell(style: .default, reuseIdentifier: editItemCellID)
            editItemTextFieldCell.editListTitleTextField.delegate = self
            guard let safeItems = items else { return UITableViewCell() }
            editItemTextFieldCell.editListTitleTextField.text = safeItems.item
            return editItemTextFieldCell
        }
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                labelCell.titleLabel.text = MenuLabel.reminder.rawValue
                labelCell.iconImageView.image = Images.BellIcon
                
                if let reminder = items?.reminderDate {
                    let today = Date()
                    if reminder.checkIf(reminderDate: reminder, isLessThan: today) {
                        print("RED REUM - EDIT ITEMS VC")
                        //TO-DO - RED FONT
                    } else {
                        labelCell.valueLabel.text = reminder
                    }
                    labelCell.valueLabel.text = reminder
                }
            case 1:
                let reminderDatePicker = reminderDatePickerCell.alertDatePicker
                alertDatePicker = reminderDatePicker
                alertDatePicker?.addTarget(self, action: #selector(reminderDatePickerChanged(sender:)), for: .valueChanged)
                return reminderDatePickerCell
            case 2:
                labelCell.titleLabel.text = MenuLabel.dueDate.rawValue
                labelCell.iconImageView.image = Images.CalendarIcon
                if let dueDate = items?.dueDate {
                    labelCell.valueLabel.text = dueDate
                }
                return labelCell
            default: return labelCell
            }
        }
        return labelCell
    }
}//DataSource

extension EditItemViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reminderDatePickerIndexPath = IndexPath(row: 0, section: 1)
        let dueDateIndexPath = IndexPath(row: 2, section: 1)
        
        if indexPath == reminderDatePickerIndexPath {
            guard let reminderDatePicker = alertDatePicker else { return }
            toggleDatePicker(datePicker: reminderDatePicker)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.beginUpdates()
                tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.endUpdates()
            }, completion: nil)
        }
        if indexPath == dueDateIndexPath {
            DispatchQueue.main.async {
                [unowned self] in
                if let items = self.items {
                    let itemTitle = items.item!
                    AddCalendarEvent(viewController: self, title: itemTitle, startDate: Date(), endDate: Date(), item: items)
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            if let reminderDatePicker = alertDatePicker {
                let height: CGFloat = reminderDatePicker.isHidden ? 0.0 : 200.0
                return height
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 { return 20 }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 10))
            footerView.backgroundColor = Colors.editItemRed
            return footerView
        }
        else { return nil }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Edit Item:"
        }
        else { return "" }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 20 }
        else { return 0 }
        
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20))
//            headerView.backgroundColor = Colors.tasksRed
//            return headerView
//        }
//        else {
//            return nil
//        }
//    }
}

extension EditItemViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            let updatedItem = textField.text!
            CoreDataManager.shared.updateItem(item: items!, text: updatedItem)
            navigationItem.rightBarButtonItem?.isEnabled = true
            textField.resignFirstResponder()
            return true
        }
        else { return false }
    }
}
