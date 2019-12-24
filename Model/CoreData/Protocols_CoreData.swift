//
//  Protocols_CoreData.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation

protocol CoreDataManagerViewController {
    var coreDataManager: CoreDataManager? { get set }
    var modelObjectType: ModelObjectType? { get set }
}



var modelObjectType: ModelObjectType?

@objc protocol ListManagedObject {
    
    var title: String? { get set }
    var recordID: NSData? { get set }
    //var isCompleted: Bool? { get set }
    var dateAdded: NSDate? { get set }
    var lastUpdatedDate: NSDate? { get set }
    var reminderDate: NSDate? { get set }
    var items: NSSet? { get set }
}

@objc protocol ItemsManagedObject {
    var item: String? { get set }
    var recordID: NSData? { get set }
    var dateAdded: NSDate? { get set }
    var lastUpdate: NSDate? { get set }
    var list: List? { get }
}
