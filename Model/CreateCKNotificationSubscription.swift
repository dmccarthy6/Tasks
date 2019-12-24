//
//  CreateCKNotificationSubscription.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import CloudKit

class CreateCKNotificationSubscription {
    
    //MARK: - PROPERTIES
    let container = CKContainer.default()
    var subscribedToPrivateChanges = false
    var subscribedToSharedChanges = false
    let privateSubscriptionID = "private-changes"
    let sharedSubscriptionID = "shared-changes"
    let createZoneGroup = DispatchGroup()
    
    func subscription() {
        let privateDB = container.privateCloudDatabase
        let sharedDB = container.sharedCloudDatabase
        
        //MARK: = Handle Private Subscriptions
        if !self.subscribedToPrivateChanges {
            let createPrivateSubscriptionOperation = self.createDatabseSubscriptionOperation(subscriptionID: privateSubscriptionID)
            createPrivateSubscriptionOperation.modifySubscriptionsCompletionBlock = { (subscriptions, deletedIDs, error) in
                if error == nil { self.subscribedToPrivateChanges = true }
                
                //TO-DO: Custom Error Handling Here?
            }
            privateDB.add(createPrivateSubscriptionOperation)
        }
        
        //MARK: - Handle Shared Subscriptions
        if !self.subscribedToSharedChanges {
            let createSharedSubscriptionOperation = createDatabseSubscriptionOperation(subscriptionID: sharedSubscriptionID)
            
            createSharedSubscriptionOperation.modifySubscriptionsCompletionBlock = { (subscriptions, deletedIDs, error) in
                if error == nil { self.subscribedToSharedChanges = true }
            }
            
            sharedDB.add(createSharedSubscriptionOperation)
        }
        
        
    }
    
    
    func createDatabseSubscriptionOperation(subscriptionID: String) -> CKModifySubscriptionsOperation {
        let subscription = CKDatabaseSubscription.init(subscriptionID: subscriptionID)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        
        //MARK: - Send Silent Notification From CK
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        operation.qualityOfService = .utility
        
        return operation
    }
    
    //USING CK/CD now, so can delete this
    //Fetch any changes from the server that happened while the app wasn't running
//    func fetchChangesWhileAppNotRunning() {
//        createZoneGroup.notify(queue: DispatchQueue.global()) {
//            if CreateCustomZone.createdCustomZone {
////                FetchChanges.fetchChanges(in: .private) {}
////                FetchChanges.fetchChanges(in: .shared) {}
//            }
//        }
//    }
}
