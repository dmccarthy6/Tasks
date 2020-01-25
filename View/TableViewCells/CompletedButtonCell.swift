

import UIKit

class CompletedButtonCell: UITableViewCell {
    
    //MARK: - Properties
    private var showCompletedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 7   //was 6
        button.contentEdgeInsets = UIEdgeInsets(top: 1, left: 7, bottom: 1, right: 7)
        button.backgroundColor = Colors.tasksRed
        button.titleLabel?.textColor = .label
        button.setTitle("Show Completed", for: .normal)
        return button
    }()
    
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createShowCompletedButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("CompletedButtonCell - init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    private func createShowCompletedButton() {
        selectionStyle = .none
        contentView.addSubview(showCompletedButton)

        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            showCompletedButton.heightAnchor.constraint(equalToConstant: Constants.completedButtonHeight),
//            showCompletedButton.topAnchor.constraint(equalTo: guide.topAnchor),
//            showCompletedButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            showCompletedButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            showCompletedButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
        ])
        
        showCompletedButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    //MARK: - Interface
    func createShowCompletedButton(withTitle: CompletedButtonTitle) {
        showCompletedButton.setTitle(withTitle.rawValue, for: .normal)
    }
    
    func setCompletedButtonTitleAfterLastCompletedItemRemoved(completedShowing: Bool) {
        if completedShowing {
            self.createShowCompletedButton(withTitle: .hideCompleted)
        }
        else {
            self.createShowCompletedButton(withTitle: .showCompleted)
        }
    }

    //MARK: - Button Functions
    fileprivate var completedButtonFunction: ( ()-> (Void) )!
    
    @objc public func whenShowCompletedTapped(_ function: @escaping () -> Void) {
        self.completedButtonFunction = function
    }
    
    @objc private func buttonTapped() {
        completedButtonFunction()
    }

    //MARK: - Unused Button
    private func animate() {
        let keyPath = "Position"
        let shake = CABasicAnimation(keyPath: keyPath)
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 4, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 4, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: keyPath)
    }
    
    private func buttonShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.5
        clipsToBounds = true
        layer.masksToBounds = false
    }
}
