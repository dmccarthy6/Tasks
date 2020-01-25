

import Foundation
import UIKit

final class ListTitleCell: UITableViewCell {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.font = DynamicFonts.Title3Dynamic
        return label
    }()
    
    private var listImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = SystemImages.ListIcon
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var listItemsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DynamicFonts.BodyDynamic
        label.textColor = .label
        label.backgroundColor = .blue
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
    
    //MARK: -
    private func createListTitleCell() {
        addSubview(listImageView)
        addSubview(titleLabel)
        //addSubview(listItemsCountLabel)
//        addConstraints()
        handleTableCellForIOS13()
        selectionStyle = .none
    }
    
    private func layoutCell() {
        selectionStyle = .none
        contentView.addSubview(listImageView)
        contentView.addSubview(titleLabel)
//        listImageView.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: titleLabel.leadingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 15), size: .init(width: 30, height: 30))
//        titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, leading: listImageView.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: contentView.frame.size.width, height: contentView.frame.size.height))
//        listItemsCountLabel.anchor(top: safeAreaLayoutGuide.topAnchor, leading: titleLabel.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 0, right: 10), size: .init(width: 20, height: -40))
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            listImageView.heightAnchor.constraint(equalTo: listImageView.widthAnchor),
            listImageView.widthAnchor.constraint(equalToConstant: 30),
            listImageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            listImageView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: listImageView.trailingAnchor, multiplier: 2)
        ])
        handleTableCellForIOS13()
    }
    
    func configure(listTitle: String) {
        titleLabel.text = listTitle
        
        accessoryType = .disclosureIndicator
        
    }
    
    //Let user set the image for the list label?
    func configureListImage(image: UIImage, tintColor: UIColor) {
        listImageView.image = image
        listImageView.tintColor = tintColor
    }
}
