//
//  CVHeaderView.swift
//  Tasks
//
//  Created by Dylan  on 1/4/20.
//  Copyright © 2020 Dylan . All rights reserved.
//

import UIKit

final class TableHeaderView: UIView {
    
    //MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .green//.systemBackground
        label.textColor = .label
        label.font = .preferredFont(for: .title3, weight: .bold)
        return label
    }()
    
    //MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutView()
    }
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//        
//        layoutView()
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    private func setupView() {
        
    }
    
    private func layoutView() {
        addSubview(titleLabel)
        //contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configureHeaderView(text: HeaderText) {
        titleLabel.text = text.rawValue
        titleLabel.backgroundColor = .purple
        print("\(text.rawValue)")
    }
}

enum HeaderText: String {
    case editItem = "Editing Item:"
    case editList = "Editing List:"
}
