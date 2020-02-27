//
//  Items+CoreDataClass.swift
//  Tasks
//
//  Created by Dylan  on 12/4/19.
//  Copyright © 2019 Dylan . All rights reserved.
//
//

import Foundation
import CoreData

@objc(Items)
public class Items: NSManagedObject {
    
    public func updateSectionIdentifier() {
        let printVal = sectionForCurrentState().rawValue
        print("ITEMSCLASS - UpdateSection: \(printVal)")
        sectionIdentifier = sectionForCurrentState().rawValue
    }
    
    private func sectionForCurrentState() -> ItemsSection {
        if isComplete {
            return .Completed
        }
        else {
            return .ToDo
        }
    }
}
