
import UIKit

final class MenuCell: UITableViewCell {
    //MARK: - Properties
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(for: .title2, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    private var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.numberOfLines = 0
        label.font = .preferredFont(for: .body, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    private var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
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
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: iconImageView.trailingAnchor, multiplier: 2),
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
        ])
    }
    
    private func setRedFontIfReminderIsPastDue(reminder: String) {
        let todaysDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd/yy h:m a"
        
        if let reminderDate = formatter.date(from: reminder) {
            if reminderDate < todaysDate {
                valueLabel.textColor = Colors.tasksRed
                valueLabel.font = .preferredFont(for: .title2, weight: .bold)
            }
        }
    }
    
    //MARK: - Interface Functions
    func configure(image: UIImage, cellLabelText: EditAllDataLabels) {
        self.iconImageView.image = image
        self.titleLabel.text = cellLabelText.rawValue
    }
    
    func configureValue(value: String?) {
        self.valueLabel.text = value ?? "Tap to add"
        
        if let value = value {
            setRedFontIfReminderIsPastDue(reminder: value)
        }
    }
    
}
