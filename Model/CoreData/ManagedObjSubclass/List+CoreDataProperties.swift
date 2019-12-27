//
//  List+CoreDataProperties.swift
//  Tasks
//
//  Created by Dylan  on 12/4/19.
//  Copyright © 2019 Dylan . All rights reserved.
//
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var dateAdded: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var lastUpdateDate: Date?
    @NSManaged public var order: Int32
    @NSManaged public var recordID: Data?
    @NSManaged public var reminderDate: String?
    @NSManaged public var title: String?
    @NSManaged public var items: NSSet?

}

extension List {
    
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Items)
    
    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Items)
    
    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)
    
    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}
