

import Foundation
import UIKit

final class ListTitleCell: UITableViewCell {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.textColor = .label
        label.font = .preferredFont(for: .title2, weight: .thin)
        return label
    }()
    
    private var listImageView: UIImageView = {
        let imageView = UIImageView() //frame: CGRect(x: 0, y: 0, width: 30, height: 30)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = SystemImages.ListIcon
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var listItemsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(for: .title2, weight: .thin)
        label.textColor = .label
        return label
    }()
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout
    private func layoutCell() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(listImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(listItemsCountLabel)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            listImageView.heightAnchor.constraint(equalTo: listImageView.widthAnchor),
            listImageView.widthAnchor.constraint(equalToConstant: 30),
            listImageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            listImageView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: listImageView.trailingAnchor, multiplier: 2),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: listItemsCountLabel.leadingAnchor, constant: 2),

            listItemsCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 10),
            listItemsCountLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            listItemsCountLabel.centerYAnchor.constraint(equalTo: listImageView.centerYAnchor)
        ])
        handleTableCellForIOS13()
    }
    
    //MARK: - Interface Methods
    
    ///Set the List title on the label and the itemsCount for the itemsCount label on the right side of the cell.
    /// - Parameters:
    ///     - listTitle: String list title value
    ///     - itemsCount: Count of the items contained in the list.
    func configure(listTitle: String, itemsCount: Int) {
        let itemsCount = String(describing: itemsCount)
        titleLabel.text = listTitle
        listItemsCountLabel.text = itemsCount
    }
    
    //Let user set the image for the list label?
    
    
    //Currently unused,
    ///
    /// - Parameters:
    ///     - image:
    ///     - tintColor:
    func configureListImage(image: UIImage, tintColor: UIColor) {
        listImageView.image = image
        listImageView.tintColor = tintColor
    }
}
