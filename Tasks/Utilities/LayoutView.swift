//
//  LayoutView.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func centerView(centerX: NSLayoutXAxisAnchor?, centerY: NSLayoutYAxisAnchor?, size: CGSize = .zero, padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func set(padding: UIEdgeInsets = .zero, for top: NSLayoutYAxisAnchor, leading: NSLayoutXAxisAnchor, trailing: NSLayoutXAxisAnchor, bottom: NSLayoutYAxisAnchor) {
        
    }
//    
//    func imageViewLayout(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?, height: CGFloat?, width: CGFloat?) {
//        translatesAutoresizingMaskIntoConstraints = false
//        if let top = top {
//            topAnchor.constraint(equalTo: top)
//        }
//        
//        if let left = left {
//            leftAnchor.constraint(equalTo: left)
//        }
//        
//        if let right = right {
//            rightAnchor.constraint(equalTo: right)
//        }
//        
//        if let height = height {
//            
//            heightAnchor.constraint(equalToConstant: height)
//        }
//        
//        if let width = width {
//            widthAnchor.constraint(equalToConstant: width)
//        }
//        
//    }
//    //    func centerView(centerXAnchor: NSLayoutXAxisAnchor, centerYAnchor: NSLayoutYAxisAnchor) {
//    //        centerXAnchor.constraint(equalTo: view).isActive = true
//    //        centerYAnchor.constraint(equalTo: <#T##NSLayoutAnchor<NSLayoutYAxisAnchor>#>).isActive = true
//    //    }
    
}
