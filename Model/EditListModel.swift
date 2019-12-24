//
//  EditListModel.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

class EditListModel {
    
    var image: UIImage
    var label: EditListLabels
    
    
    init(image: UIImage, label: EditListLabels) {
        self.image = image
        self.label = label
    }
    
    
}

enum EditListLabels: String {
    case edit = "Edit List"
    case share = "Share"
    
}
