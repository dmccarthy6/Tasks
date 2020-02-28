//
//  UINavigationControllerExt.swift
//  Tasks
//
//  Created by Dylan  on 12/31/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

extension UINavigationItem {
    
    ///Create the navigation bar with this method. Takes a title string and two optional bar button items to set the nav bar buttons.
    /// - Parameters:
    ///     - title: Title for the navigation bar
    ///     - leftItem: Optional UIBarButtonItem on the left side of the nav bar
    ///     - rightItem: Optional UIBarButtonItem on the right side of the nav bar
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
