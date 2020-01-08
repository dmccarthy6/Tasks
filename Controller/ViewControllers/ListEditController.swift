
import UIKit
import TasksFramework

final class EditListViewController: UIViewController {

    //MARK: - Properties
    private lazy var tableView: UITableView = {
        let editListTableView = UITableView(frame: view.frame)
//        let editListTableView = UITableView(frame: .zero, style: .plain)
        editListTableView.dataSource = self
        editListTableView.delegate = self
        editListTableView.registerCell(cellClass: MenuCell.self)
        editListTableView.register(EditItemCell.self, forCellReuseIdentifier: editListCellID)
        editListTableView.separatorStyle = .singleLine
        editListTableView.tableFooterView = UIView()
        return editListTableView
    }()
    private var data = [EditListMenuModel]()
    private let editListCellID = "EditListCell"
    private let headerHeight: CGFloat = 55
    private var tableViewCellHeight: CGFloat = 60
    var list: List?

    
    //MARK: - Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        setModelData()
        
        navigationItem.createNavigationBar(title: "",
                                        leftItem: UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel)),
                                        rightItem: UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleDone)))
    }
    
    /*
     Using below to creat modal view of the Edit List Controller. Will need to re work this VC to accomplish.
     */
    func setModalHeight() {
        if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            window.addSubview(tableView)
            let numberOfRows: CGFloat = CGFloat(3)
            let height: CGFloat = numberOfRows * tableViewCellHeight
            tableView.frame = CGRect(x: 0,
                                     y: window.frame.height-100.0,
                                     width: window.frame.width,
                                     height: height)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.handleThemeChange()
        NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
    }
    
    //MARK: - Helpers
    private func createView() {
        view.addSubview(tableView)
        
        navigationItem.createNavigationBar(title: "",
                                           leftItem: UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel)),
                                           rightItem: UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleDone)))

        doneButton(isEnabled: false)
    }

    private func setModelData() {
        data.append(EditListMenuModel(image: SystemImages.CheckCircleFill!, label: .saveList))
    }
    
    private func doneButton(isEnabled: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
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

}

//MARK: - UITableView Data Source Methods
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
            menuCell.configure(image: Images.SaveIcon!,
                               tintColor: .white,
                               text: menuData.label.rawValue)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return createHeaderView()
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
    
    private func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: tableView.frame.size.width,
                                              height: headerHeight))
        let titleLabel = UILabel(frame: CGRect(x: 10,
                                               y: 0,
                                               width: tableView.frame.size.width,
                                               height: headerHeight))
        headerView.backgroundColor = .systemBackground
        titleLabel.textColor = .label
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.text = HeaderText.editList.rawValue
        headerView.addSubview(titleLabel)
        return headerView
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
