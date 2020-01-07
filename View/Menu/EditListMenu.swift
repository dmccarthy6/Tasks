//
//  EditListMenu.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditListMenu: NSObject {
    
    //MARK: - Properties
    lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.registerCell(cellClass: MenuCell.self)
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .singleLine
        tv.separatorColor = .white
        tv.tableFooterView = UIView()
        return tv
    }()
    let cellHeight: CGFloat = 75
    var list: List?
    var menuData: [EditListModel] = []
    var menuIsShowing: Bool = false
    let tabBar = TasksTabBarController()
    
    
    override init() {
        super.init()

        setMenuData()
    }
    
    func setMenuData() {
        menuData.append(EditListModel(image: Images.EditIcon!, label: .edit))
    }
    
    
    
    @objc func showEditListMenu() {
        if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            window.addSubview(overlayView)
            window.addSubview(tableView)
            menuIsShowing = true
            
            let tabBarHeight = window.getTabBarSize()!
    
            let height: CGFloat = CGFloat(2)*cellHeight//#Rows)
            let y = (window.frame.height - height) - tabBarHeight
            
            tableView.frame = CGRect(x: 0, y: window.frame.height-tabBarHeight, width: window.frame.width, height: 0)
            overlayView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height - tabBarHeight)
            overlayView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.transitionCurlUp], animations: {
                self.overlayView.alpha = 1
                self.tableView.frame = CGRect(x: 0, y: y, width: self.tableView.frame.width, height: height)
            }, completion: nil)
        }
    }
    
    @objc func showEditListMenuIpad() {
        
    }
    
    @objc func handleDismiss() {
        menuIsShowing = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            self.overlayView.alpha = 0
            if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
                let tabBarOffset = window.getTabBarSize()!
                let y = window.frame.height - tabBarOffset
                self.tableView.frame = CGRect(x: 0, y: y, width: self.tableView.frame.width, height: 0) //window.frame.height //self.tableView.frame.height-tabBarOffset
            }
        }, completion: nil)
    }

    func showEditListViewController() {
        let editVC = EditListViewController()
        let nav = UINavigationController(rootViewController: editVC)
        handleDismiss()
        
        let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first
        let viewController = window?.visibleViewController()
        editVC.list = list
        viewController?.present(nav, animated: true, completion: nil)
    }
    
}//
extension EditListMenu: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let menuCell = tableView.dequeueReusableCell(withIdentifier: menuID, for: indexPath) as! MenuCell
        let menuCell: MenuCell = tableView.dequeueReusableCell(for: indexPath)
        let data = menuData[indexPath.row]
        menuCell.configure(image: data.image, tintColor: Colors.tasksRed, text: data.label.rawValue)
        
        //menuCell.backgroundColor = Colors.tasksRed
        //menuCell.setMenuCellColors()

        
//        menuCell.titleLabel.text = data.label.rawValue
//        menuCell.iconImageView.image = data.image
        
        return menuCell
    }
}

extension EditListMenu: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = menuData[indexPath.row]
        
        if cellData.label == EditListLabels.edit {
            showEditListViewController()
        }
    }
    
}//
    
//    func popoverOnIPad() {
//        menuIsShowing = true
//        let tabBarHeight = window.getTabBarSize()!
//
//                let height: CGFloat = CGFloat(2)*cellHeight//#Rows)
//                let y = (window.frame.height - height) - tabBarHeight
//
//                tableView.frame = CGRect(x: 0, y: window.frame.height-tabBarHeight, width: window.frame.width, height: 0)
//                overlayView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height - tabBarHeight)
//                overlayView.alpha = 0
//
//                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.transitionCurlUp], animations: {
//                    self.overlayView.alpha = 1
//                    self.tableView.frame = CGRect(x: 0, y: y, width: self.tableView.frame.width, height: height)
//                }, completion: nil)
//            }
////        if UIDevice.current.userInterfaceIdiom == .pad {
////            let ac = UIAlertController(title: <#T##String?#>, message: <#T##String?#>, preferredStyle: .actionSheet)
////            let popover = ac.popoverPresentationController
////            popover?.sourceView = tabBar.editListController.tabBarItem
////            present(ac, animated: true)
////        }
//    }
