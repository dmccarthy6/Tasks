//
//  UINavigationControllerExt.swift
//  Tasks
//
//  Created by Dylan  on 12/31/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

extension UINavigationItem {
    
    func createNavigationBar(title: String, leftItem: UIBarButtonItem?, rightItem: UIBarButtonItem?) {
        
        //Set Bar Buttons (If Needed)
        if let leftBarButton = leftItem {
            leftBarButtonItem = leftBarButton
        }
        
        if let rightBarButton = rightItem {
            rightBarButtonItem = rightBarButton
        }
        
        //Set Nav Bar Title
        self.title = title
    }
    
}

//UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
