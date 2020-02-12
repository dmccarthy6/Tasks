
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import UIKit
import TasksFramework

struct OpenInTasks {
    
    /*
     This file is for the Share Extension to open the shared item in Tasks, if the app is downloaded on the users system.
     Will update this once I update the share extension.
     */
    
    static func openInTasks(items: [Items]) -> TasksActivity {
        //let tasksImage = ""//TO-DO - Get Image Here
        
        let openTasksAction = TasksActivity(title: "Open In Tasks", image: nil) { (sharedItems) in
            //Items & Title Here
            
            let url = URL(string: "tasksopen://")
            UIApplication.shared.open(url!) { (success) in
                if success {
                    print("Opened Tasks!")
                }
                else {
                    //provide App Store Link?
                }
            }
        }
        return openTasksAction
    }
    
}
