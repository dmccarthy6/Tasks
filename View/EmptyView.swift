
//  Created by Dylan  on 1/23/20.
//  Copyright © 2020 Dylan . All rights reserved.
//

import UIKit

final class EmptyView: UIView {
    
    let emptyDataLabel: UILabel = {
        let label = UILabel()
        label.text = "No Data"
        label.font = .preferredFont(for: .headline, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    let iconView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    
    //MARK: - Interface
    func setEmptyViewData(message: EmptyViewMessage, icon: UIImage) {
        emptyDataLabel.text = message.message
        iconView.image = icon
    }
    
    
    enum EmptyViewMessage: String {
        case emptyList
        
        var message: String {
            switch self {
            case .emptyList: return "The list is empty"
            }
        }
    }
    
//    enum EmptyViewIcon: UIImage {
//        typealias RawValue = UIImage
//        case emptyList
//        
//        var image: UIImage {
//            switch self {
//            case .emptyList: return UIImage(systemName: "hand.thumbsup.fill")!
//            }
//        }
//    }
}
