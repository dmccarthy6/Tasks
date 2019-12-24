//
//  MenuModel.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

class MenuModel: NSObject {
    
    var image: UIImage
    var label: MenuLabel
    var date: String?
    
    
    
    init(image: UIImage, label: MenuLabel, date: String?) {
        self.image = image
        self.label = label
        self.date = date
        
        super.init()
    }
    
    
    
}
