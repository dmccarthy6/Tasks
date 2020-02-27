
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//


//Edit List Labels
enum EditListLabel: String, CaseIterable {
    case edit           = "Edit Title"
    case shareList      = "Share List"
    
    static var count: Int {
        EditListLabel.allCases.count
    }
}

/*
 Only the EditItem Label
 */
//Edit Item Labels
enum EditItemLabel: String, CaseIterable {
    case saveList = "Save"
    
    static var count: Int {
        EditItemLabel.allCases.count
    }
}


//Edit Item
/*
 All Labels, This is used in the 'EditListModel' Struct so that it can be reused in the EditItem VC and the EditList VC.
 */
enum EditAllDataLabels: String, CaseIterable {
    case edit           = "Edit Title"
    case shareList      = "Share List"
    case saveList       = "Save"
    
    case reminder = "Reminder"
    case dueDate = "Due Date"
}
