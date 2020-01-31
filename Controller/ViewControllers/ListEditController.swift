
import UIKit
import TasksFramework

final class EditListViewController: UIViewController, CanWriteToDatabase {
    
    //MARK: - Properties
    private lazy var tableView: UITableView = {
        let editListTableView = UITableView(frame: .zero, style: .plain)
        editListTableView.translatesAutoresizingMaskIntoConstraints = false
        editListTableView.backgroundColor = .systemBackground
        editListTableView.dataSource = self
        editListTableView.delegate = self
        editListTableView.registerCell(cellClass: MenuCell.self)
        editListTableView.register(EditItemCell.self, forCellReuseIdentifier: editListCellID)
        editListTableView.separatorStyle = .singleLine
        editListTableView.tableFooterView = UIView()
        return editListTableView
    }()
    private var data = [EditListModel]()
    private let editListCellID = "EditListCell"
    private let headerHeight: CGFloat = 55
    var list: List?
    
    
    
    //MARK: - Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        setData()
    }
    
    func setData() {
        data.append(EditListModel(image: SystemImages.AddListIcon!, labelText: EditAllDataLabels.saveList))
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.handleThemeChange()
        NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
    }
    
    
    //MARK: - Helpers
    private func createView() {
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        
        navigationItem.createNavigationBar(title: "Edit List",
                                           leftItem: UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped)),
                                           rightItem: UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped)))
        tableView.setFullScreenTableViewConstraints(in: view)
        saveButton(isEnabled: false)
    }
    
    private func saveButton(isEnabled: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
    
    //MARK: - Button Functions
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveTapped() {
        //TO-DO: Alert user that the list was saved.
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITableView Data Source Methods
extension EditListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 { return 0 }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuCell: MenuCell = tableView.dequeueReusableCell(for: indexPath)
        if indexPath.section == 0 {
            let editListCell = EditItemCell(style: .default, reuseIdentifier: editListCellID)
            editListCell.configure(text: list?.title ?? "",
                                   delegate: self)
            return editListCell
        }
        if indexPath.section == 1 {
            let editListData = data[indexPath.row]
            menuCell.configure(image: editListData.image,
                               cellLabelText: editListData.labelText)
            return menuCell
        }
        return UITableViewCell()
    }
}

//MARK: - UITableView Delegate Methods
extension EditListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            saveTapped()
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        switch section {
//        case 0:
//            return createHeaderView()
//        case 1: return nil
//        default: return nil
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        switch section {
//        case 0: return headerHeight
//        case 1: return 0
//        default: return 0
//        }
//    }
    
    private func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: tableView.frame.size.width,
                                              height: headerHeight))
        let titleLabel = UILabel()
        headerView.backgroundColor = .systemBackground
        titleLabel.textColor = .label
        titleLabel.font = .preferredFont(for: .title2,
                                         weight: .semibold)
        titleLabel.text = "Edit List"//HeaderText.editList.rawValue
        headerView.addSubview(titleLabel)
        titleLabel.centerView(centerX: headerView.centerXAnchor,
                              centerY: headerView.centerYAnchor)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
}

//MARK: - UITextField Delegate Methods
extension EditListViewController: UITextFieldDelegate {
    
    //    func textFieldDidBeginEditing(_ textField: UITextField) {
    //        doneButton(isEnabled: true)
    //    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let list = list, let updatedTitle = textField.text {
            self.updateObject(object: list, value: updatedTitle, entity: .List)
        }
        textField.resignFirstResponder()
        tableView.reloadData()
        saveButton(isEnabled: true)
        return true
    }
    
}
