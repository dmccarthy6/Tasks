//
//  DeletedItems+CoreDataProperties.swift
//  Tasks
//
//  Created by Dylan  on 12/4/19.
//  Copyright © 2019 Dylan . All rights reserved.
//
//

import Foundation
import CoreData


extension DeletedItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeletedItems> {
        return NSFetchRequest<DeletedItems>(entityName: "DeletedItems")
    }

    @NSManaged public var recordID: Data?
    @NSManaged public var recordType: String?

}
