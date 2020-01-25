
import UIKit


final class CompletedItemsCell: UITableViewCell, CanWriteToDatabase {
    
    //MARK: - Properties
    private var itemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = DynamicFonts.BodyDynamic
        label.backgroundColor = .systemBackground
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private var completedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.CircleWithCheck, for: .normal)
        button.tintColor = Colors.tasksRed
        button.backgroundColor = .systemBackground
        
        return button
    }()
    
    private var flaggedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.Star, for: .normal)
        button.backgroundColor = .systemBackground
        button.tintColor = Colors.tasksRed
        return button
    }()
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set Up Completed Cell And Completed Button
//    private func createCompletedTasksCell() {
//        if #available(iOS 13.0, *) {
//            completedButton.tintColor = Colors.tasksRed
//            completedButton.backgroundColor = .systemBackground
//            itemLabel.backgroundColor = .systemBackground
//        }
//        else {
//            completedButton.setImage(Images.CompletedTasksIcon, for: .normal)
//            completedButton.tintColor = Colors.tasksRed
//            completedButton.backgroundColor = .clear
//            itemLabel.backgroundColor = .clear
//        }
//        selectionStyle = .none
//
//        setupLayout()
//    }

    //MARK: - Set Cell Constraints
    private func setupLayout() {
        contentView.addSubview(completedButton)
        contentView.addSubview(itemLabel)
        contentView.addSubview(flaggedButton)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
                completedButton.topAnchor.constraint(equalTo: guide.topAnchor),
                completedButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
                completedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
                completedButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                
                itemLabel.topAnchor.constraint(equalTo: guide.topAnchor),
                itemLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
                itemLabel.leadingAnchor.constraint(equalTo: completedButton.trailingAnchor),
                
                flaggedButton.topAnchor.constraint(equalTo: completedButton.topAnchor),
                flaggedButton.bottomAnchor.constraint(equalTo: completedButton.bottomAnchor),
                flaggedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
                flaggedButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
        flaggedButton.addTarget(self, action: #selector(flaggedButtonTapped), for: .touchUpInside)
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
    }
    
    func configure(item: String) {
        self.itemLabel.attributedText = strikeThroughTextFor(item)
    }
    
    func handleUserTapCompletedOrFavorite(for item: Items, isFlagged: Bool, tableView: UITableView) {
        
        whenFlaggedButtonTapped { [unowned self] in
            self.setItemAsFlagged(item: item, status: !isFlagged)
            self.flaggedButton.setImage((isFlagged ? SystemImages.Star : SystemImages.StarFill), for: .normal)
            self.flaggedButton.tintColor = isFlagged ? Colors.tasksRed : Colors.tasksYellow
            tableView.reloadData()
        }
        whenCompletedButtonTapped { [unowned self] in
            self.setItemCompletedStatus(item: item)
            tableView.reloadData()
        }
    }
    
    private func strikeThroughTextFor(_ item: String) -> NSAttributedString {
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: Colors.tasksRed,
        ]
        
        let attributedStringWithAttributes = NSAttributedString(string: item, attributes: attributes)
        return attributedStringWithAttributes
    }
    
    //MARK: - Button Functions
    private var completedButtonFunc: (() -> (Void))!
    private var flaggedButtonFunc: (() -> (Void))!
    
    @objc func completedButtonTapped() {
        completedButtonFunc()
    }
    
    @objc func flaggedButtonTapped() {
        flaggedButtonFunc()
    }
    
    @objc func whenCompletedButtonTapped(_ function: @escaping () -> Void) {
        self.completedButtonFunc = function
    }
    
    @objc func whenFlaggedButtonTapped(_ function: @escaping () -> Void) {
        self.flaggedButtonFunc = function
    }
    
}
