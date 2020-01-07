//
//  CustomCollectionViewCell.swift
//  Tasks
//
//  Created by Dylan  on 1/3/20.
//  Copyright © 2020 Dylan . All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    //MARK: - Properties
    
    private let colorIconButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    //MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCardCell()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    private func setupCardCell() {
        contentView.backgroundColor = .systemBackground
        //Any other cell setup here
    }
    
    private func setupLayout() {
        contentView.addSubview(colorIconButton)
        
        
        NSLayoutConstraint.activate([
            colorIconButton.topAnchor.constraint(equalTo: topAnchor),
            colorIconButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            colorIconButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorIconButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        
        ])
    }
    
    //MARK: -
    func configure(image: UIImage, color: UIColor) {
        colorIconButton.setImage(image, for: .normal)
        colorIconButton.tintColor = color
    }
    
}
