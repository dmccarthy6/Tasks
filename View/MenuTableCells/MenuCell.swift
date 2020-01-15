
import UIKit

final class MenuCell: UITableViewCell {
    //MARK: - Properties
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(for: .title2, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    private var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.font = .preferredFont(for: .body, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    private var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
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
        
        iconImageView.anchor(top: safeAreaLayoutGuide.topAnchor,
                             leading: safeAreaLayoutGuide.leadingAnchor,
                             bottom: safeAreaLayoutGuide.bottomAnchor,
                             trailing: titleLabel.leadingAnchor,
                             padding: .init(top: 0, left: 5, bottom: 0, right: 10),
                             size: .init(width: iconImageView.image?.size.width ?? 30, height: iconImageView.image?.size.height ?? 30))
        
        titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor,
                          leading: iconImageView.trailingAnchor,
                          bottom: safeAreaLayoutGuide.bottomAnchor,
                          trailing: valueLabel.leadingAnchor,
                          padding: .init(top: 0, left: 0, bottom: 0, right: 0),
                          size: .init(width: frame.size.width/2, height: cellHeight))
        
        valueLabel.anchor(top: safeAreaLayoutGuide.topAnchor,
                          leading: titleLabel.trailingAnchor,
                          bottom: safeAreaLayoutGuide.bottomAnchor,
                          trailing: safeAreaLayoutGuide.trailingAnchor,
                          padding: .init(top: 0, left: 0, bottom: 0, right: 10),
                          size: .init(width: frame.size.width/2, height: cellHeight))
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
