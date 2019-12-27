//
//  ListTitleCell.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

class ListTitleCell: UITableViewCell {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = DynamicFonts.Title3Dynamic
        return label
    }()
    
    private var listImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Images.ListIcon
        return iv
    }()
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createListTitleCell()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    func createListTitleCell() {
        addSubview(listImageView)
        addSubview(titleLabel)
        addConstraints()
        handleTableCellForIOS13()
        selectionStyle = .none
    }
    
    private func addConstraints() {
        let listImage = Images.ListIcon! //Force Unwrapping?!?
        listImageView.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: titleLabel.leadingAnchor, padding: .init(top: 0, left: 3, bottom: 0, right: 0), size: .init(width: listImage.size.width, height: listImage.size.height))
        titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, leading: listImageView.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: contentView.frame.size.width, height: contentView.frame.size.width))
    }
    
    func configure(listTitle: String) {
        titleLabel.text = listTitle
    }
}
