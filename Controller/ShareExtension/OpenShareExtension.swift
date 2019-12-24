//
//  OpenShareExtension.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

struct OpenShareExtension {
    
    let items: [Items]
    
    init(items: [Items]) {
        self.items = items
        showShareExtension()
    }
    
    func showShareExtension() {
        let item = items.map({ $0.item! })
        
        let shareViewController = ShareActivityController(activityItems: item, applicationActivities: nil)
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), let controller = window.visibleViewController() {
            controller.present(shareViewController, animated: true)
        }
    }
    
}
