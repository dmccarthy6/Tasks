//
//  UITableViewCellExtension.swift
//  Tasks
//
//  Created by Dylan  on 12/26/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    static var cellReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView {
    static var viewReuseIdentifier: String {
        return String(describing: self)
    }
    
}

extension UITableView {
    
    func registerCell<T: UITableViewCell>(cellClass: T.Type) {
        register(T.self, forCellReuseIdentifier: T.cellReuseIdentifier)
    }
    
    func registerView<T: UITableViewHeaderFooterView>(viewClass: T.Type) {
     register(T.self, forHeaderFooterViewReuseIdentifier: T.viewReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let reuseIdentifier = T.cellReuseIdentifier
        
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? T
            else {
                assertionFailure("Unable to deque cell for \(reuseIdentifier)")
                return T()
        }
        return cell
    }
    
    func dequeueReusableView<T: UITableViewHeaderFooterView>() -> T {
        let reuseIdentifier = T.viewReuseIdentifier
        
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? T
            else {
                assertionFailure("Unable to dequeu view for \(reuseIdentifier)")
                return T()
        }
        return view
    }
   
    
    ///Sets the constraints of the tableview to the view's anchors. 
    /// - Parameters:
    ///     - view: The UIView that the tableview sits in
    func setFullScreenTableViewConstraints(in view: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func handleEmptyView(isEmpty: Bool, view: EmptyView) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundView = isEmpty ? view : nil
        }
    }
}

