//
//  Extensions_CoreData.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func insertTitle<A :NSManagedObject>() -> A where A :ListManagedObject {
        guard let insertedObject = NSEntityDescription.insertNewObject(forEntityName: ModelObjectType.List.rawValue, into: self) as? A else {
            fatalError("Wrong Object Type")
        }
        return insertedObject
    }
   
    func insertListItem<A :NSManagedObject>() -> A where A :ItemsManagedObject {
        guard let insertedItem = NSEntityDescription.insertNewObject(forEntityName: ModelObjectType.Items.rawValue, into: self) as? A else {
            fatalError("Wrong Item Object Type")
        }
        return insertedItem
    }
    
    
}
