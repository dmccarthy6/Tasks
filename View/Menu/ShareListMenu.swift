//
//  ShareListMenu.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import EventKit
import CoreData

class ShareListMenuLauncher: NSObject {
    
    lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        return view
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = Colors.tasksRed
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .white
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    let cellHeight: CGFloat = 75
    var list: List?
    var menuData: [EditListModel] = []
    var isMenuShowing: Bool = false
    let shareCellID = "ShareCell"
    let tabBar = TasksTabBarController()
    
    
    
    override init() {
        super.init()
        registerTableViewCells()
        setMenuData()
    }
    
    
    @objc func showShareMenu() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(overlayView)
            window.addSubview(tableView)
            isMenuShowing = true
            
            let tabBarHeight = window.getTabBarSize()!
            
            let height: CGFloat = CGFloat(2)*cellHeight
            let y = (window.frame.height - height) - tabBarHeight
            
            //Set Frames for TableView Menu && The Overlay View
            tableView.frame = CGRect(x: 0, y: window.frame.height-tabBarHeight, width: window.frame.width, height: 0)
            overlayView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height - tabBarHeight)
            overlayView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.overlayView.alpha = 1
                self.tableView.frame = CGRect(x: 0, y: y, width: self.tableView.frame.width, height: height)
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        isMenuShowing = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.overlayView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                let tabBarOffset = window.getTabBarSize()!
                let y = window.frame.height - tabBarOffset
                self.tableView.frame = CGRect(x: 0, y: y, width: self.tableView.frame.width, height: 0)
            }
        }) { (completed: Bool) in
        }
    }
    
    func setMenuData() {
        menuData.append(EditListModel(image: Images.ShareIcon!, label: .share))
    }
    
    func registerTableViewCells() {
        tableView.register(MenuCell.self, forCellReuseIdentifier: shareCellID)
    }
    
}
extension ShareListMenuLauncher: UITableViewDataSource {
    //MARK: - TableView Data Source Methods:
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shareMenuCell = tableView.dequeueReusableCell(withIdentifier: shareCellID, for: indexPath) as? MenuCell
        shareMenuCell?.setMenuCellColors()
        
        let cellData = menuData[indexPath.row]
        shareMenuCell?.titleLabel.text = cellData.label.rawValue
        shareMenuCell?.iconImageView.image = cellData.image
        return shareMenuCell!
    }
    
}

extension ShareListMenuLauncher: UITableViewDelegate {
    //MARK: UITableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = menuData[indexPath.row]
        if cell.label == EditListLabels.share {
            
            if let items = list?.items  {
                OpenShareExtension(items: [items])
            }
//            if let items = list?.items?.allObjects as? [Items] {
//                OpenShareExtension(items: items)
//            }
        }
    }
}
