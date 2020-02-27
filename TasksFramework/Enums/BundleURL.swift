//  Created by Dylan  on 2/10/20.
//  Copyright © 2020 Dylan . All rights reserved.
//


enum BundleURL {
    case ListsViewController
    case ItemsViewController
}

extension BundleURL: Endpoint {
    var scheme: String {
        return "tasksopen"
    }
    
    var host: String {
        switch self {
        case .ListsViewController:     return ""
        case .ItemsViewController:    return "Item"
        }
    }
    
    var path: String {
        return ""
    }
}
