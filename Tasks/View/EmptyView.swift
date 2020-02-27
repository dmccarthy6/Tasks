
//  Created by Dylan  on 1/23/20.
//  Copyright © 2020 Dylan . All rights reserved.
//

import UIKit

final class EmptyView: UIView {
    //MARK: - Properties
    let emptyDataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(for: .title1, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "hand.thumbsup")
        imageView.tintColor = Colors.tasksRed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Layout
    private func setupView() {
        addSubview(emptyDataLabel)
        addSubview(iconView)
        
        NSLayoutConstraint.activate([
            emptyDataLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            emptyDataLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            iconView.topAnchor.constraint(equalToSystemSpacingBelow: emptyDataLabel.bottomAnchor, multiplier: 5),
            iconView.widthAnchor.constraint(equalToConstant: 70),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            iconView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    
    
    //MARK: - Interface
    func setEmptyViewData(message: EmptyDataMessage) {
        emptyDataLabel.text = message.message
    }

}

enum EmptyDataMessage: String {
    case emptyList
    case emptyItems
    
    var message: String {
        switch self {
        case .emptyList:            return "Looks like you completed all your Tasks, great job!"
        case .emptyItems:           return "You are crushing it! All your tasks have been completed."
        }
    }
}
