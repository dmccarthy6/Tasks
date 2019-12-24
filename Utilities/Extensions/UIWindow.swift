//
//  UIWindow.swift
//  Tasks
//
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
    
    func getTabBarSize() -> CGFloat? {
        if let rootVC: UIViewController = self.rootViewController {
            return UIWindow.getTabBarControllerFrom(rootVC)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(_ vc: UIViewController) -> UIViewController {
        
        if vc.isKind(of: UINavigationController.self) {
            let navigationCotntroller = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom(navigationCotntroller.visibleViewController!)
            
        } else if vc.isKind(of: UITabBarController.self) {
            let tabBarController = vc as! TasksTabBarController
            return UIWindow.getVisibleViewControllerFrom(tabBarController.selectedViewController!)
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(presentedViewController.presentedViewController!)
            } else {
                return vc
            }
        }
    }
    
    class func getTabBarControllerFrom(_ vc: UIViewController) -> CGFloat {
        if vc.isKind(of: UINavigationController.self) {
            let navigationController = vc as! UINavigationController
            return UIWindow.getTabBarControllerFrom(navigationController.visibleViewController!)
            
        } else if vc.isKind(of: UITabBarController.self) {
            let tabBarController = vc as! TasksTabBarController
            return tabBarController.tabBar.frame.size.height
        }
        return 100
    }
    
}

