
import UIKit
import TasksFramework

final class CompletedItemsCell: UITableViewCell, CanWriteToDatabase {
    
    //MARK: - Properties
    private var itemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(for: .title2, weight: .thin)
        label.backgroundColor = .systemBackground
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private var completedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setImage(SystemImages.CircleWithCheck, for: .normal)
        button.tintColor = Colors.tasksRed
        button.backgroundColor = .systemBackground
        
        return button
    }()
    
    private var flaggedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
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
    
    //MARK: - Set Cell Constraints
    private func setupLayout() {
        selectionStyle = .none
        
        contentView.addSubview(completedButton)
        contentView.addSubview(itemLabel)
        contentView.addSubview(flaggedButton)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
                completedButton.widthAnchor.constraint(equalToConstant: Constants.itemCellButtonWidth),
                completedButton.heightAnchor.constraint(equalTo: completedButton.widthAnchor),
                completedButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                completedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
                
                itemLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: completedButton.trailingAnchor, multiplier: 1),
                itemLabel.topAnchor.constraint(equalTo: guide.topAnchor),
                itemLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
                
                flaggedButton.widthAnchor.constraint(equalToConstant: Constants.itemCellButtonWidth),
                flaggedButton.heightAnchor.constraint(equalTo: flaggedButton.heightAnchor),
                flaggedButton.leadingAnchor.constraint(equalToSystemSpacingAfter: itemLabel.trailingAnchor, multiplier: 1),
                flaggedButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
                flaggedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
        ])
        flaggedButton.addTarget(self, action: #selector(flaggedButtonTapped), for: .touchUpInside)
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
    }
    
    func configure(item: Items) {
        self.itemLabel.attributedText = strikeThroughTextFor(item.item)
        
        self.flaggedButton.setImage(item.isFlagged ? SystemImages.StarFill : SystemImages.Star, for: .normal)
        self.flaggedButton.tintColor = item.isFlagged ? .systemYellow : Colors.tasksRed
    }
    
    
    ///Toggle the isFavorite status on the item when user taps the button in cell.
    /// - Parameters:
    ///     - item: Item setting flagged status on
    ///     - isFlagged: Current isFlagged status
    ///     - tableView: Tableview where the cell is
    func userChangedFlagged(item: Items, isFlagged: Bool, tableView: UITableView) {
        self.setItemAsFlagged(item: item, status: !isFlagged)
        self.flaggedButton.setImage((isFlagged ? SystemImages.Star : SystemImages.StarFill), for: .normal)
        self.flaggedButton.tintColor = isFlagged ? Colors.tasksRed : .systemYellow
        tableView.reloadData()
    }
    
    ///Sets the isComplete status in Core Data.
    /// - Parameters:
    ///     - item: Item being set as complete.
    func userTappedComplete(item: Items) {
        self.setItemCompletedStatus(item: item)
    }
    
    private func strikeThroughTextFor(_ item: String?) -> NSAttributedString {
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: Colors.tasksRed,
        ]
        
        let attributedStringWithAttributes = NSAttributedString(string: item ?? "", attributes: attributes)
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
