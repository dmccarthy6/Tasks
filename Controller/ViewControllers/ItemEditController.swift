//
//  ItemEditController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import EventKit
import TasksFramework

class EditItemViewController: UIViewController, CanWriteToDatabase, EventAddedDelegate {
    //MARK: - Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.registerCell(cellClass: MenuCell.self)
        tableView.registerCell(cellClass: EditItemCell.self)
        tableView.registerCell(cellClass: ReminderDatePickerCell.self)
        return tableView
    }()
    var datePicker: UIDatePicker?
    private var datePickerIsHidden: Bool = true
    var itemBeingEdited: Items?
   
    
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        doneButton(isEnabled: false)
    }
    
    
    //TO-DO: Trait Collection Methods Here?
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
    
    //MARK: - Helpers
    private func setupView() {
        view.addSubview(tableView)
        
        navigationItem.createNavigationBar(title: "",
                                           leftItem: nil,
                                           rightItem: UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped)))
        tableView.setFullScreenTableViewConstraints(in: view)
    }
    
    //MARK: - UIDatePicker Methods
    func setTargetOnCellDatePicker(pickerCell: ReminderDatePickerCell) {
        let picker = pickerCell.alertDatePicker
        picker.addTarget(self, action: #selector(handleDatePickerChanged(sender:)), for: .valueChanged)
    }
    
    @objc func handleDatePickerChanged(sender: UIDatePicker) {
        let reminderCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! MenuCell
        let pickerDateAsString = sender.date.getReminderDateAsString(pickerDate: sender.date)
        
        //Save reminder date to item in Core Data
        if let item = itemBeingEdited {
            setAlertOnItem(item: item, alertDate: sender.date)
            doneButton(isEnabled: true)
        }
        //Set Reminder Label in MenuCell
        reminderCell.configureValue(value: pickerDateAsString)
    }
    
    //MARK: - EKEventKit Methods -- Adding Due Date To Calendar
    internal func eventAdded(event: EKEvent) {
        guard let items = itemBeingEdited else { return }
        let eventDate = event.startDate
        setDueDateForItem(item: items, date: eventDate!)
    }
    
    //MARK: - UINavigation Methods
    @objc func doneButtonTapped() {
        //TO-DO: Reverse Navigation Here?
        
    }
    
    private func doneButton(isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
    
}//

//MARK: - UITableView Data Source Methods
extension EditItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 {
            if datePickerIsHidden {
                return 2
            }
            else if !datePickerIsHidden {
                return 3
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let labelCell: MenuCell = tableView.dequeueReusableCell(for: IndexPath(row: indexPath.row, section: 1))
        
        if indexPath.section == 0 {
            let editItemTextFieldCell: EditItemCell = EditItemCell(style: .default, reuseIdentifier: TableViewCellIDs.editItemCellID.rawValue)
            if let safeItems = itemBeingEdited, let item = safeItems.item {
                editItemTextFieldCell.configure(text: item, delegate: self)
            }
            return editItemTextFieldCell
        }
        if indexPath.section == 1 {
            if datePicker == nil {
                let cells = cellForRowPickerIsNotShowing(indexPath: indexPath, cell: labelCell)
                return cells
            }
            else if datePicker != nil {
                let cells = pickerIsShowing(indexPath: indexPath, labelCell: labelCell)
                return cells
            }
           
//            if datePickerIndexPath == indexPath {
//                let reminderDatePickerCell = ReminderDatePickerCell(style: .default, reuseIdentifier: TableViewCellIDs.reminderDatePickerID.rawValue)
//                setTargetOnCellDatePicker(pickerCell: reminderDatePickerCell)
//                return reminderDatePickerCell
//            }
//            switch indexPath.row {
//            case 0://REMINDERS
//                labelCell.configure(image: SystemImages.BellReminderIcon!, cellLabelText: EditAllDataLabels.reminder)
//                if let items = itemBeingEdited, let reminder = items.reminderDate {
//                    labelCell.configureValue(value: reminder)
//                }
//            case 1://DATE PICKER
//                datePickerIndexPath = indexPath
//                let reminderDatePickerCell = ReminderDatePickerCell(style: .default, reuseIdentifier: TableViewCellIDs.reminderDatePickerID.rawValue)
//                setTargetOnCellDatePicker(pickerCell: reminderDatePickerCell)
//                return reminderDatePickerCell
//            case 2://DUE DATE
//                labelCell.configure(image: SystemImages.CalendarIcon!, cellLabelText: EditAllDataLabels.dueDate)
//                if let dueDate = itemBeingEdited?.dueDate {
//                    labelCell.configureValue(value: dueDate)
//                }
//                return labelCell
//            default: return labelCell
//            }
        }
        return labelCell
    }
    
    //MARK: - Helpers
    func cellForRowPickerIsNotShowing(indexPath: IndexPath, cell: MenuCell)  -> UITableViewCell {
        switch indexPath.row {
        case 0:
            //Reminder Text Cell (Above Date Picker Row)
            cell.configure(image: SystemImages.BellReminderIcon!, cellLabelText: EditAllDataLabels.reminder)
            if let item = itemBeingEdited, let reminder = item.reminderDate {
                cell.configureValue(value: reminder)
            }
            return cell
        case 1:
            cell.configure(image: SystemImages.CalendarIcon!, cellLabelText: EditAllDataLabels.dueDate)
            if let dueDate = itemBeingEdited?.dueDate {
                cell.configureValue(value: dueDate)
            }
            return cell
        default: ()
        }
        return UITableViewCell()
    }
    
    func pickerIsShowing(indexPath: IndexPath, labelCell: MenuCell) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            labelCell.configure(image: SystemImages.BellReminderIcon!, cellLabelText: EditAllDataLabels.reminder)
            if let item = itemBeingEdited, let reminder = item.reminderDate {
                labelCell.configureValue(value: reminder)
            }
            return labelCell
        case 1:
            //DatePickerCell
            let datePickerCell = ReminderDatePickerCell(style: .default, reuseIdentifier: TableViewCellIDs.reminderDatePickerID.rawValue)
            datePickerCell.alertDatePicker.isHidden = false
            datePicker = datePickerCell.alertDatePicker
            setTargetOnCellDatePicker(pickerCell: datePickerCell)
            return datePickerCell
        case 2:
            labelCell.configure(image: SystemImages.CalendarIcon!, cellLabelText: EditAllDataLabels.dueDate)
            if let dueDate = itemBeingEdited?.dueDate {
                labelCell.configureValue(value: dueDate)
            }
            return labelCell
        default: ()
        }
        return UITableViewCell()
    }
}

//MARK: - UITableView Delegate Methods
extension EditItemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexAboveDatePicker = IndexPath(row: 0, section: 1)
        let datePickerIndex = IndexPath(row: 1, section: 1)
        if indexPath == indexAboveDatePicker && datePicker == nil {
            datePickerIsHidden = false
            datePicker = UIDatePicker()
            
            UIView.animate(withDuration: 0.3) {
                self.tableView.beginUpdates()
                self.tableView.deselectRow(at: datePickerIndex, animated: true)
                self.tableView.insertRows(at: [datePickerIndex], with: .automatic)
                
                self.tableView.endUpdates()
            }
        }
        else if indexPath == indexAboveDatePicker && datePicker != nil {
            datePickerIsHidden = true
            datePicker = nil
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [datePickerIndex], with: .automatic)
            self.tableView.endUpdates()
        }
        //        let aboveDatePickerCell = IndexPath(row: 1, section: 1)
        //        let datePickerIP = IndexPath(row: 2, section: 1)
        //        tableView.beginUpdates()
        //        if let datePickerIndex = datePickerIndexPath  {
        //            if aboveDatePickerCell.row == indexPath.row {
        //                //If date picker is showing and you tapped the cell above it -- delete row and remove
        //                tableView.deleteRows(at: [datePickerIndex], with: .fade)
        //                self.datePickerIndexPath = nil
        //            }
        //        }
        //        else if datePickerIndexPath == nil && indexPath == aboveDatePickerCell {
        //            print("INSERTING DATE PICKER")
        //            datePickerIndexPath = datePickerIP
        //            tableView.insertRows(at: [datePickerIP], with: .fade)
        //        }
    }
//        let reminderDatePickerIndexPath = IndexPath(row: 0, section: 1)
//        let dueDateIndexPath = IndexPath(row: 2, section: 1)
//
//        if indexPath == reminderDatePickerIndexPath {
//            /* Animate the cell date picker showing */
//            let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! ReminderDatePickerCell
//            cell.toggleDatePicker()
//            UIView.animate(withDuration: 0.3, animations: {
//                self.tableView.beginUpdates()
//                tableView.deselectRow(at: indexPath, animated: true)
//                self.tableView.endUpdates()
//            }, completion: nil)
//        }
//        if indexPath == dueDateIndexPath {
//            /*Open the calendar, if user gave access, to add Task to calendar. */
//            if let items = self.itemBeingEdited, let itemTitle = items.item {
//                let calendarManager = CalendarManager()
//                calendarManager.eventAddedDelegate = self
//                DispatchQueue.main.async { [unowned self] in
//                    calendarManager.addItemToCalendar(self, title: itemTitle, startDate: Date(), endDate: Date(), item: items)
//                }
//            }
//        }
    
    
//    func didSelect() {
//        let aboveDatePickerCell = IndexPath(row: 1, section: 1)
//        let datePickerIP = IndexPath(row: 2, section: 1)
//        tableView.beginUpdates()
//        if let datePickerIndex = datePickerIndexPath, aboveDatePickerCell = IndexPath.row {
//            //If date picker is showing and you tapped the cell above it -- delete row and remove
//            tableView.deleteRows(at: [datePickerIndex], with: .fade)
//            self.datePickerIndexPath = nil
//        }
//        else if datePickerIndexPath == nil && indexPath.row == aboveDatePickerCell {
//            datePickerIndexPath = datePickerIP
//            tableView.insertRows(at: [datePickerIP], with: .fade)
//        }
//
//        //If date picker isn't nil (it's showing) and the selected row is above the date picker we need to hide the date picker
//        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
//            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
//            self.datePickerIndexPath = nil
//        }
//        else {
//            if let datePickerIndexPath = datePickerIndexPath {
//                tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
//            }
//            datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
//            tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
//            tableView.deselectRow(at: IndexPath, animated: true)
//        }
//        tableView.endUpdates()
//    }
//
//    func indexPathToInsertDatePicker(indexPath: IndexPath) -> IndexPath {
//        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
//            return indexPath
//        }
//        else {
//            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
//        }
//    }
    
    /* Set Date Picker Cell Height when the cell is tapped*/
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let datePickerIndexPath = IndexPath(row: 1, section: 1)
        if indexPath == datePickerIndexPath && datePicker != nil {
            //We have a date picker
            let height: CGFloat = datePicker != nil ? 250 : 0
            return height
//        var isPickerHidden = true
//
//        if indexPath == datePickerIndexPath {
//            if let datePickerCell = tableView.cellForRow(at: datePickerIndexPath) as? ReminderDatePickerCell {
//                isPickerHidden = datePickerCell.alertDatePicker.isHidden
//                let height: CGFloat = isPickerHidden ? 0.0 : 200.0
//                return height
//            }
//            else {
//                let height: CGFloat = isPickerHidden ? 0.0 : 200.0
//                return height
//            }
            //return 0
        }
        return UITableView.automaticDimension
    }
    
    //MARK: - UITableView Header Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return createdHeaderView()
        }
        else { return nil }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 50 }
        else { return 0 }
    }
    
    //MARK: - UITableView Footer Methods
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 { return createFooterView() }
        else { return nil }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 { return 20 }
        else { return 0 }
    }
    
    //MARK: - Header & Footer Helpers
    private func createdHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: tableView.frame.size.width,
                                              height: 50))
        let label = UILabel()
        headerView.backgroundColor = .systemBackground
        label.backgroundColor = .systemBackground
        label.text = "Label Text:"
        label.font = .preferredFont(for: .title3, weight: .semibold)
        label.textColor = .label
        headerView.addSubview(label)
        label.centerView(centerX: headerView.centerXAnchor, centerY: headerView.centerYAnchor)
        
        return headerView
    }
    
    private func createFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: tableView.frame.size.width,
                                              height: 50))
        footerView.backgroundColor = .systemBackground
        return footerView
    }
}

//MARK: - UITextField Delegate Methods
extension EditItemViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            let updatedItem = textField.text!
            if let object = itemBeingEdited {
                self.updateObject(object: object, value: updatedItem, entity: .Items)
            }
            //doneButton(isEnabled: true)
            textField.resignFirstResponder()
            return true
        }
        else { return false }
    }
}

