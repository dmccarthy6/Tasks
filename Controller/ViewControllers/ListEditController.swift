//
//  ListEditController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import TasksFramework

final class EditListViewController: UIViewController {

    //MARK: - Properties
    lazy var tableView: UITableView = {
        let editListTableView = UITableView(frame: view.frame)
        editListTableView.dataSource = self
        editListTableView.delegate = self
        editListTableView.registerCell(cellClass: MenuCell.self)
        editListTableView.register(EditItemCell.self, forCellReuseIdentifier: editListCellID)
        editListTableView.separatorStyle = .singleLine
        editListTableView.tableFooterView = UIView()
        return editListTableView
    }()

    var data = [EditListMenuModel]()
    let editListCellID = "EditListCell"
    var list: List?
    let headerHeight: CGFloat = 55



    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        setModelData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.handleThemeChange()
        NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
    }

    func createView() {
        view.addSubview(tableView)
        //\(list?.title ?? "")
        navigationItem.createNavigationBar(title: "", leftItem: UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel)), rightItem: UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleDone)))
//        //Setting 'Done' button to false until the user edits the list title -- then it becomes enabled
        doneButton(isEnabled: false)
    }

    func setModelData() {
        data.append(EditListMenuModel(image: SystemImages.CheckCircleFill!, label: .saveList))
    }

    //MARK: - Button Functions
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func handleDone() {
//        let window = UIWindow()
//        let vc = window.visibleViewController()
        //Alerts.showNormalAlert(self, title: "List Saved", message: "Your list title has been changed to \(list?.title ?? "nil")")
        dismiss(animated: true, completion: nil)
    }

    //MARK: - Helpers
    func doneButton(isEnabled: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
}

//MARK: UITableView Data Source Methods
extension EditListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 { return data.count }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuCell: MenuCell = tableView.dequeueReusableCell(for: indexPath)
        if indexPath.section == 0 {
            let editListCell = EditItemCell(style: .default, reuseIdentifier: editListCellID)
            editListCell.configure(text: list?.title ?? "", delegate: self)
            return editListCell
        }
        if indexPath.section == 1 {
            let menuData = data[indexPath.row]
            menuCell.configure(image: Images.SaveIcon!, tintColor: .white, text: menuData.label.rawValue)
            return menuCell
        }
        return UITableViewCell()
    }
}

//MARK: - UITableView Delegate Methods
extension EditListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            handleDone()
        }
    }
    
    //Section Header    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width, height: headerHeight))
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHeight))
            headerView.backgroundColor = .systemBackground
            titleLabel.textColor = .label
            titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
            titleLabel.text = HeaderText.editList.rawValue
            headerView.addSubview(titleLabel)
            return headerView
//            let header = TableHeaderView()
//            header.configureHeaderView(text: .editList)
//            return header
        case 1: return nil
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return headerHeight
        case 1: return 0
        default: return 0
        }
    }
    
}

//MARK: - UITextField Delegate Methods
extension EditListViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        doneButton(isEnabled: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let list = list else { return false }
        let newTitle = textField.text
        CoreDataManager.shared.updateListTitle(list: list, newTitle: newTitle!)
        textField.resignFirstResponder()
        tableView.reloadData()
        doneButton(isEnabled: true)
        return true
    }

}
