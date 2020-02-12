//
//  TasksTabBarController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import TasksFramework

class TasksTabBarController: UITabBarController {
    
    //MARK: - Properties
    var tabBarCont = UITabBarController()
    let addItemsToListVC = AddItemsToListViewController()
    let editListController = EditListViewController()
    
//    lazy var editListMenu: EditListMenu = {
//        let editList = EditListMenu()
//        return editList
//    }()
//
//    lazy var shareListMenu: ShareListMenuLauncher = {
//       let shareList = ShareListMenuLauncher()
//        return shareList
//    }()
    
    var currentList: List?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBarController()
        self.delegate = self
    }
    
    func setUpTabBarController() {
        tabBarCont = UITabBarController()
        tabBarCont.tabBar.barStyle = .default
        
        UITabBar.appearance().unselectedItemTintColor = Colors.tasksRed
        addItemsToListVC.tabBarItem = UITabBarItem(title: "Share", image: Images.ShareIcon!, tag: 0)
        editListController.tabBarItem = UITabBarItem(title: "Edit List", image: Images.EditIcon!, tag: 1)
        
        //Add View Controllers to Tab Bar
        let controllers = [addItemsToListVC, editListController]
        
        viewControllers = controllers.map {
            UINavigationController(rootViewController: $0)
        }
    }
    
    
    
}//CLASS

extension TasksTabBarController: UITabBarControllerDelegate {
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        
//        if viewController.isKind(of: UINavigationController.self) {
//            if let navVC = viewController as? UINavigationController {
//                
//                guard let visibleVC = navVC.visibleViewController else {
//                    fatalError("Error No VC")
//                }
//                
//                if visibleVC.isKind(of: EditListViewController.self) {
//                    
//                    shareListMenu.handleDismiss()
//                    handleEditMenu(editListMenu: editListMenu)
//                    return false
//                }
//                if visibleVC.isKind(of: AddItemsToListViewController.self) {
//                    
//                    editListMenu.handleDismiss()
//                    handleShareMenu(shareListMenu: shareListMenu)
//                    return false
//                }
//            }
//        }
//        return true
//    }
    
//    func handleEditMenu(editListMenu: EditListMenu) {
//        if editListMenu.menuIsShowing {
//
//            editListMenu.handleDismiss()
//        }
//        else {
//            editListMenu.showEditListMenu()
//            editListMenu.list = currentList
//        }
//    }
//
//    func handleShareMenu(shareListMenu: ShareListMenuLauncher) {
//        if shareListMenu.isMenuShowing {
//
//            shareListMenu.handleDismiss()
//        }
//        else {
//            shareListMenu.showShareMenu()
//            shareListMenu.list = currentList
//        }
//    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == addItemsToListVC.tabBarItem {
            print("SHARE ITEMS TAPPED")
            tabBarCont.selectedIndex = 0
        } else if item == editListController.tabBarItem {
            print("EDIT ITEMS TAPPED ")
            tabBarCont.selectedIndex = 1
        }
    }
    
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        if item.tag == 1 {
//            //setViewControllers([mainViewController], animated: true)
//            menuLauncher.showReminderMenu()
//        }
//    }
    
}

