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

extension UITableView {
    
    func registerCell<T: UITableViewCell>(cellClass: T.Type) {
        register(T.self, forCellReuseIdentifier: T.cellReuseIdentifier)
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
}
