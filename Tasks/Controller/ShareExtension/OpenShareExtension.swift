
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import TasksFramework

struct OpenShareExtension {
    
    //MARK: - Open Share Extension
    func showShareExtensionInItemsActionSheet(items: [Items], popoverItem: UIBarButtonItem?) {
        let items = items.compactMap({ $0.item! })
        let shareViewController = ShareActivityController(activityItems: items, applicationActivities: nil)
        
        if let popoverController = shareViewController.popoverPresentationController {
            popoverController.barButtonItem = popoverItem
        }
        rootViewController().present(shareViewController, animated: true)
    }
    
    func showShareExtensionInList(_ viewController: UIViewController, items: [Items], popoverView: UIView) {
        let items = items.compactMap({ $0.item! })
        let shareViewController = ShareActivityController(activityItems: items, applicationActivities: nil)
        
        if let popoverController = shareViewController.popoverPresentationController {
            popoverController.sourceView = popoverView
        }
        
        viewController.present(shareViewController, animated: true)
    }
    
    //MARK: - Helpers
    private func rootViewController() -> UIViewController {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), let rootVC = window.visibleViewController() {
            return rootVC
        }
        return UIViewController()
    }
}
