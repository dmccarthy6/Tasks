
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import TasksFramework

struct OpenShareExtension {
//    //MARK: - Properties
//    let items: [Items]
//    
//    
//    //MARK: - Initializer
//    init(items: [Items]) {
//        self.items = items
//        showShareExtension()
//    }
//    
//    
//    //MARK: -
//    func showShareExtension() {
//        let item = items.map({ $0.item! })
//        
//        let shareViewController = ShareActivityController(activityItems: item, applicationActivities: nil)
//        
//        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), let controller = window.visibleViewController() {
//            controller.present(shareViewController, animated: true)
//        }
//    }
    
    //MARK: - Open Share Extension
    func showShareExtensionActionSheet(items: [Items], popoverItem: UIBarButtonItem?) {
        let items = items.compactMap({ $0.item! })
        let shareViewController = ShareActivityController(activityItems: items, applicationActivities: nil)
        
        if let popoverSharePresentation = shareViewController.popoverPresentationController {
            popoverSharePresentation.barButtonItem = popoverItem
        }
        
        rootViewController().present(shareViewController, animated: true)
    }
    
    
    //MARK: - Helpers
    private func rootViewController() -> UIViewController {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), let rootVC = window.visibleViewController() {
            return rootVC
        }
        return UIViewController()
    }
}
