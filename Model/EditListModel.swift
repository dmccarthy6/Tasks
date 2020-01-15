//
//  EditListModel.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit

struct EditListModel: Hashable {
    var id = UUID().uuidString
    var image: UIImage
    var labelText: EditAllDataLabels
    
    static func == (lhs: EditListModel, rhs: EditListModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension EditListModel {
    static var editItems: [EditListModel] {
        return [
            EditListModel(image: SystemImages.BellReminderIcon!, labelText: EditAllDataLabels.reminder),
            EditListModel(image: SystemImages.CalendarIcon!, labelText: EditAllDataLabels.dueDate)
        ]
    }
    
    static var editList: [EditListModel] {
        return [
            EditListModel(image: SystemImages.AddListIcon!, labelText: EditAllDataLabels.saveList)
        ]
    }
}
