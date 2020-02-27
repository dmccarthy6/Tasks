//
//  Items+CoreDataProperties.swift
//  Tasks
//
//  Created by Dylan  on 12/4/19.
//  Copyright © 2019 Dylan . All rights reserved.
//
//

import Foundation
import CoreData


extension Items {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Items> {
        return NSFetchRequest<Items>(entityName: "Items")
    }

    @NSManaged public var dateAdded: Date?
    @NSManaged public var dueDate: String?
    @NSManaged public var isComplete: Bool
    @NSManaged public var isFlagged: Bool
    @NSManaged public var item: String?
    @NSManaged public var lastUpdatedDate: Date?
    @NSManaged public var order: Int32
    @NSManaged public var recordID: Data?
    @NSManaged public var reminderDate: String?
    @NSManaged public var sectionIdentifier: String?
    @NSManaged public var titleID: String?
    @NSManaged public var list: List?

}
