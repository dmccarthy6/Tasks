//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(rootViewController)
        }
        return nil
    }
    
    
    class func getVisibleViewControllerFrom(_ vc: UIViewController) -> UIViewController {
        
        if vc.isKind(of: UINavigationController.self) {
            let navigationCotntroller = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom(navigationCotntroller.visibleViewController!)
            
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(presentedViewController.presentedViewController!)
            } else {
                return vc
            }
        }
    }
    
    
}

