//  Created by Dylan  on 2/12/20.
//  Copyright © 2020 Dylan . All rights reserved.
//

import UIKit
import TasksFramework

final class EmptyWidgetView: UIView {
    
    //MARK: - Properties
    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .center
        label.font = .preferredFont(for: .title2, weight: .medium)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Helpers
    private func setupView() {
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    //MARK: - Interface
    func configureEmptyView(text: EmptyDataText) {
        label.text = text.message
    }
}
