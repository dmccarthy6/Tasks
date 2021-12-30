//  Created by Dylan  on 2/29/20.
//  Copyright © 2020 Dylan . All rights reserved.

import UIKit

final class NoteViewCell: UITableViewCell, CanWriteToDatabase {
    
    //MARK: - Properties
    private var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .systemBackground
        textView.font = .preferredFont(for: .body, weight: .medium)
        return textView
    }()
    
    
    //MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Layout
    private func setupCell() {
        contentView.addSubview(textView)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            textView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
        ])
    }
    
    //MARK: - Interface
    func configureNotesCell(noteText: String) {
        self.textView.text = noteText
    }
}
