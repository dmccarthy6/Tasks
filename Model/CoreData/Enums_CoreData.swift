//
//  Enums_CoreData.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation

enum ModelObjectType: String {
    
    case List = "List"
    case Items = "Items"
    case DeletedCloudKitObject = "DeletedCloudKitObject"
    
    
    static let allCloudKitModelObjectTypes = [
        ModelObjectType.List.rawValue,
        ModelObjectType.Items.rawValue
    ]
    
    
    
}
