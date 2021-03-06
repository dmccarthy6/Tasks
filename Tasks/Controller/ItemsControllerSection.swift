//
//  ItemsControllerSection.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import CoreData

final class ControllerSectionInfo {
    
    private let section: ItemsSection
    let fetchedIndex: Int?
    private let fetchController: NSFetchedResultsController<NSFetchRequestResult>
    private var fetchedInfo: NSFetchedResultsSectionInfo? {
        guard let index = fetchedIndex else {
            return nil
        }
        return fetchController.sections![index]
    }
    
    init(section: ItemsSection, fetchedIndex: Int?, fetchController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.section = section
        self.fetchedIndex = fetchedIndex
        self.fetchController = fetchController
    }
    
}

extension ControllerSectionInfo: NSFetchedResultsSectionInfo {
    @objc var name: String { return section.title }
    @objc var indexTitle: String? { return "" }
    @objc var numberOfObjects: Int { return fetchedInfo?.numberOfObjects ?? 0 }
    @objc var objects: [Any]? { return fetchedInfo?.objects as [AnyObject]?? ?? [] }
}
