
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation

enum ItemsSection: String {
    
    case Completed = "1"
    case ToDo = "0"
    
    var title: String {
        switch self {
        case .Completed:
            return "Completed"
        case .ToDo:
            return "ToDo"
        }
    }
    
}
