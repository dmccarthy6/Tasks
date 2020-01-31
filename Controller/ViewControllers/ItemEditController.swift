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

class EditItemViewController: UIViewController, CanWriteToDatabase {
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
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.isHidden = true
        datePicker.minimumDate = Date()
        datePicker.backgroundColor = .secondarySystemBackground
        datePicker.addTarget(self, action: #selector(handleDatePickerChanged(sender:)), for: .valueChanged)
        return datePicker
    }()
    private var datePickerIsHidden: Bool = true
    var itemBeingEdited: Items?
   
    
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    
    //TO-DO: Trait Collection Methods Here?
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
    
    //MARK: - Helpers
    private func setupView() {
        view.addSubview(tableView)
        
        navigationItem.createNavigationBar(title: "Edit Item", leftItem: nil, rightItem: nil)
        tableView.setFullScreenTableViewConstraints(in: view)
    }
    
    //MARK: - UIDatePicker Methods
    @objc func handleDatePickerChanged(sender: UIDatePicker) {
        let reminderCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! MenuCell
        let pickerDateAsString = sender.date.getReminderDateAsString(pickerDate: sender.date)
        
        //Save reminder date to item in Core Data
        if let item = itemBeingEdited {
            setAlertOnItem(item: item, alertDate: sender.date)
        }
        //Set Reminder Label in MenuCell
        reminderCell.configureValue(value: pickerDateAsString)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
    }
    
    //MARK: - EKEventKit Methods -- Adding Due Date To Calendar
    internal func eventAdded(event: EKEvent) {
        guard let items = itemBeingEdited else { return }
        let eventDate = event.startDate
        setDueDateForItem(item: items, date: eventDate!)
        tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
    }

}//

//MARK: - UITableView Data Source Methods
extension EditItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 { return 3 }
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
            switch indexPath.row {
            case 0:
                labelCell.configure(image: SystemImages.BellReminderIcon!, cellLabelText: EditAllDataLabels.reminder)
                if let item = itemBeingEdited, let reminderDate = item.reminderDate {
                    labelCell.configureValue(value: reminderDate)
                }
                return labelCell
            case 1:
                //Date Picker
                let datePickerCell = ReminderDatePickerCell(style: .default, reuseIdentifier: TableViewCellIDs.reminderDatePickerID.rawValue)
                datePickerCell.alertDatePicker = datePicker
                return datePickerCell
            case 2:
                labelCell.configure(image: SystemImages.CalendarIcon!, cellLabelText: EditAllDataLabels.dueDate)
                if let dueDate = itemBeingEdited?.dueDate {
                    labelCell.configureValue(value: dueDate)
                }
            default: return UITableViewCell()
            }
        }
        return labelCell
    }

}

//MARK: - UITableView Delegate Methods
extension EditItemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexAboveDatePicker = IndexPath(row: 0, section: 1)
        if indexPath == indexAboveDatePicker {
            datePicker.isHidden.toggle()
            if let pickerCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? ReminderDatePickerCell {
                pickerCell.setPickerConstraints()
            }
            UIView.animate(withDuration: 0.3) {
                self.tableView.beginUpdates()
                tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.endUpdates()
            }
        }
        else if indexPath == IndexPath(row: 2, section: 1) {
            let calendarManager = CalendarManager()
            
            if let toDoItem = itemBeingEdited, let item = toDoItem.item {
                calendarManager.presentModalCalendarController(title: item, startDate: Date(), endDate: Date()) { (result) in
                    switch result {
                    case .success(let controller):
                        DispatchQueue.main.async {
                            controller.editViewDelegate = calendarManager
                            self.present(controller, animated: true)
                        }
    
                    case .failure(let calendarError):
                        switch calendarError {
                        case .calendarAccessDeniedOrRestricted:
                            DispatchQueue.main.async { Alerts.showSettingsAlert(self, message: CalendarAlertsMessage.restricted.rawValue) }
                            
                        case .eventNotAddedToCalendar:
                            print("Not Added To Calendar")
                        case .notDetermined:
                            print("Not Determined")
                        case .eventAlreadyExistsInCalendar:
                            DispatchQueue.main.async { Alerts.showSettingsAlert(self, message: CalendarAlertsMessage.eventExists.rawValue) }
                        }
                    }
                }
            }
        }
    }

    /* Set Date Picker Cell Height when the cell is tapped*/
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let datePickerIndexPath = IndexPath(row: 1, section: 1)
        if indexPath == datePickerIndexPath {
            //We have a date picker
            let height: CGFloat = datePicker.isHidden ? 0 : 250
            return height
        }
        return UITableView.automaticDimension
    }
    
    //MARK: - UITableView Header Methods
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            return createdHeaderView()
//        }
//        else { return nil }
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 { return 30 }
//        else { return 0 }
//    }

    //MARK: - Header & Footer Helpers
    private func createHeaderView() -> UIView {
        let headerView = UIView()
        let label = UILabel()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.backgroundColor = .blue
        label.backgroundColor = .systemBackground
        label.text = "Edit Item:"
        label.font = .preferredFont(for: .title3, weight: .semibold)
        label.textColor = .label
        
        view.addSubview(headerView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            label.topAnchor.constraint(equalToSystemSpacingBelow: headerView.topAnchor, multiplier: 1),
            label.leadingAnchor.constraint(equalToSystemSpacingAfter: headerView.leadingAnchor, multiplier: 2),
        ])
        return headerView
    }
    
//    private func createFooterView() -> UIView {
//        let footerView = UIView(frame: CGRect(x: 0,
//                                              y: 0,
//                                              width: tableView.frame.size.width,
//                                              height: 50))
//        footerView.backgroundColor = .systemBackground
//        return footerView
//    }
}

//MARK: - UITextField Delegate Methods
extension EditItemViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            let updatedItem = textField.text!
            if let object = itemBeingEdited {
                self.updateObject(object: object, value: updatedItem, entity: .Items)
            }
            textField.resignFirstResponder()
            return true
        }
        else { return false }
    }
}

extension EditItemViewController: EventAddedDelegate {
    
    var item: Items? {
        if let item = itemBeingEdited {
            return item
        }
        return nil
    }
    
    
}
