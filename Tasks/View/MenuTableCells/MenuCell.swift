
import UIKit

final class MenuCell: UITableViewCell {
    //MARK: - Properties
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(for: .title3, weight: .regular)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    private var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.numberOfLines = 0
        label.font = .preferredFont(for: .body, weight: .regular)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    private let cellHeight: CGFloat = 50
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createMenuCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    //width: iconImageView.image?.size.width ?? 0.0, height: iconImageView.image?.size.height ?? 0.0))
    private func createMenuCell() {
        selectionStyle = .none
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: iconImageView.trailingAnchor, multiplier: 1),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
        ])
    }
    
    private func setRedFontIfReminderIsPastDue(reminder: String) {
        let todaysDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM/dd/yyyy h:mm a"
        
        if let reminderDate = formatter.date(from: reminder) {
            if reminderDate < todaysDate {
                valueLabel.textColor = Colors.tasksRed
                valueLabel.font = .preferredFont(for: .body, weight: .semibold)
            }
        }
    }
    
    //MARK: - Interface Functions
    
    ///Sets the cell image and text for the title labels.
    /// - Parameters:
    ///     - image: UIImage for icon in the cell
    ///     - titleLabelText: Enum value that sets the
    func configureCell(image: UIImage, titleLabelText: EditAllDataLabels) {
        self.iconImageView.image = image
        self.titleLabel.text = titleLabelText.rawValue
    }
    
    ///Configure the value label in the cell with the Reminder date or Due date selected by the user.
    /// - Parameters:
    ///     - valueText: String value representing the Due Date and Reminder Date
    func configureCellValues(valueText: String?) {
        self.valueLabel.text = valueText
        if let value = valueText {
            setRedFontIfReminderIsPastDue(reminder: value)
        }
    }
    
}
