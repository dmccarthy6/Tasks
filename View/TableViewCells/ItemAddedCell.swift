

import UIKit

class ItemAddedCell: UITableViewCell, CanWriteToDatabase {

    //MARK: - Properties
    var openItemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = DynamicFonts.BodyDynamic
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    var completedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.CircleBlank, for: .normal)
        button.tintColor = Colors.tasksRed
        button.backgroundColor = .systemBackground
        
        return button
    }()
    var flaggedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.Star, for: .normal)
        button.tintColor = Colors.tasksRed
        button.backgroundColor = .systemBackground
        
        return button
    }()
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createCell()
    }
    //Draw Tableview Cell Separator so you can hae them only in the open cells section?
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//        let context = UIGraphicsGetCurrentContext()
//        context!.setStrokeColor(UIColor.blue.cgColor)
//        context?.setLineWidth(0.5)
//        context?.move(to: CGPoint(x: 0.0, y: rect.width))
//        context?.addLine(to: CGPoint(x: rect.height, y: rect.width))
//        context?.strokePath()
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set Up Items Cell
//    private func configureItemsAddedCell() {
//        if #available(iOS 13.0, *) {
//            completedButton.setImage(SystemImages.CircleBlank, for: .normal)
//            completedButton.tintColor = Colors.tasksRed
//
//            completedButton.backgroundColor = .systemBackground
//            openItemLabel.backgroundColor = .systemBackground
//        }
//        else {
//            completedButton.setImage(Images.CheckBoxBlankRedIcon, for: .normal)
//
//            completedButton.backgroundColor = .clear
//            openItemLabel.backgroundColor = .clear
//        }
//
//        selectionStyle = .none
//        setLayout()
//    }
    
    //MARK: - Set Layout Constraints
    private func createCell() {
        selectionStyle = .none
        //let config = UIImage.SymbolConfiguration(scale: <#T##UIImage.SymbolScale#>)
        contentView.addSubview(completedButton)
        contentView.addSubview(openItemLabel)
        contentView.addSubview(flaggedButton)

        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            completedButton.widthAnchor.constraint(equalToConstant: 50),
            completedButton.heightAnchor.constraint(equalTo: completedButton.widthAnchor),
            completedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            completedButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            
            openItemLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            openItemLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            openItemLabel.leadingAnchor.constraint(equalTo: completedButton.trailingAnchor),
            openItemLabel.trailingAnchor.constraint(equalTo: flaggedButton.leadingAnchor),

            flaggedButton.widthAnchor.constraint(equalToConstant: 50),
            flaggedButton.heightAnchor.constraint(equalTo: flaggedButton.widthAnchor),
            flaggedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            flaggedButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
        
        
        flaggedButton.addTarget(self, action: #selector(flaggedButtonTapped), for: .touchUpInside)
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
    }

    //MARK: - Interface
    func configureCell(itemText: String) {
        self.openItemLabel.text = itemText
    }
    
    func handleUserTapFlagOrFavoriteButtons(for item: Items, isFlagged: Bool, tableView: UITableView) {
        
        whenFlaggedButtonTapped {
            self.setItemAsFlagged(item: item, status: !isFlagged)
            self.flaggedButton.setImage((isFlagged ? SystemImages.StarFill : SystemImages.Star), for: .normal)
            self.flaggedButton.tintColor = isFlagged ? Colors.tasksYellow : Colors.tasksRed
            tableView.reloadData()
        }
        whenCompletedButtonTapped {
            self.setItemCompletedStatus(item: item)
            tableView.reloadData()
        }
    }
    
    //MARK: - Button Functions
       private var completedButtonFunc: (() -> (Void))!
       private var flaggedButtonFunc: (() -> (Void))!
       
       @objc func completedButtonTapped() {
           completedButtonFunc()
       }
       
       @objc func flaggedButtonTapped() {
           flaggedButtonFunc()
       }
       
       @objc func whenCompletedButtonTapped(_ function: @escaping () -> Void) {
           self.completedButtonFunc = function
       }
       
       @objc func whenFlaggedButtonTapped(_ function: @escaping () -> Void) {
           self.flaggedButtonFunc = function
       }
}
