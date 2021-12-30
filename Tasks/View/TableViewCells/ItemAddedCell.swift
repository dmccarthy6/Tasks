

import UIKit
import TasksFramework

class ItemAddedCell: UITableViewCell, CanWriteToDatabase {

    //MARK: - Properties
    private var openItemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(for: .title2, weight: .thin)
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    private var completedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setImage(SystemImages.CircleBlank, for: .normal)
        button.tintColor = Colors.tasksRed
        button.contentMode = .scaleAspectFit
        return button
    }()
    private var flaggedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setImage(SystemImages.Star, for: .normal)
        button.contentMode = .scaleAspectFit
        button.tintColor = Colors.tasksRed
        return button
    }()
    
    
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Set Layout Constraints
    private func createCell() {
        selectionStyle = .none
        //let config = UIImage.SymbolConfiguration(scale: <#T##UIImage.SymbolScale#>)
        contentView.addSubview(completedButton)
        contentView.addSubview(openItemLabel)
        contentView.addSubview(flaggedButton)

        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            completedButton.widthAnchor.constraint(equalToConstant: Constants.itemCellButtonWidth),
            completedButton.heightAnchor.constraint(equalTo: completedButton.widthAnchor),
            completedButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            completedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            
            openItemLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: completedButton.trailingAnchor, multiplier: 1),
            openItemLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            openItemLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            
            flaggedButton.widthAnchor.constraint(equalToConstant: Constants.itemCellButtonWidth),
            flaggedButton.heightAnchor.constraint(equalTo: flaggedButton.widthAnchor),
            flaggedButton.leadingAnchor.constraint(equalToSystemSpacingAfter: openItemLabel.trailingAnchor, multiplier: 1),
            flaggedButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            flaggedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
        ])
        flaggedButton.addTarget(self, action: #selector(flaggedButtonTapped), for: .touchUpInside)
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
    }
    
    
    //MARK: - Interface
    func configureCell(item: Items) {
        self.openItemLabel.text = item.item
        
        //Flagged Button
        self.flaggedButton.setImage(item.isFlagged ? SystemImages.StarFill! : SystemImages.Star!, for: .normal)
        self.flaggedButton.tintColor = item.isFlagged ? .systemYellow : Colors.tasksRed
        
    }

    ///Changes the flagged status in Core Data.
    /// - Parameters:
    ///     - item: Item chaning the flagged status on
    ///     - isFlagged: Current item 'isFlagged' status
    ///     - tableView: The tableView the cell sits in
    func userTappedFlaggedButton(item: Items, isFlagged: Bool, tableView: UITableView) {
        self.setItemAsFlagged(item: item, status: !isFlagged)
        self.flaggedButton.setImage((isFlagged ? SystemImages.StarFill : SystemImages.Star), for: .normal)
        self.flaggedButton.tintColor = isFlagged ? .systemYellow : Colors.tasksRed
        tableView.reloadData()
    }
    
    ///Sets the item as completed in Core Data.
    /// - Parameters:
    ///     - item: Item setting as completed
    func userTappedCompletedButton(item: Items) {
        self.setItemCompletedStatus(item: item)
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
