# Tasks

## Updates In Version 2.0:
* Added NSPersistentCloudKitContainer to improve the Core Data/CloudKit Sync.
* Updated and simplified the User Interface to improve the User Experience.
* Added today and share extensions to improve User Experience.
* Added support for iOS 13.0 and Dark Mode!
***
![iOS](https://camo.githubusercontent.com/be4ac65adac5e6b3d4471f37169496f617e7a544/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f506c6174666f726d2d694f532d6c69676874677265792e737667) ![Swift](https://camo.githubusercontent.com/e92bf630e2a25eeecfe64818a7a3ff05b862bfb8/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5377696674253230352e302d627269676874677265656e2e737667)
## Description:
A to-do list application that syncs to-do's across all your iOS Devices. Add reminders for important tasks, For things you really can't forget you can add them to your calendar right from the app. This application is written in Swift 5.1.

***
## Technologies: 
* **UITableView:** Using UITableView for the list views in the project. 
* **UITabBarController:** TabBarController used to display menus to share or edit lists. 
* **Core Data:** Core Data used for local persistence. Save lists, tasks, reminders, and due dates all using Core Data.
* **CloudKit:** Used NSPersistentCloudKitContainer to perform Core Data/CloudKit Sync.
* **Today Extension:** Use the today widget to view any items that have a reminder date set for that day.
* **Share Extension:** Share tasks via share window.
* **Custom Animations:** Custom animations used on custom menus that appear and disappear from the tab bar.  
* **Programatic UI:** Built the UI programatically without the use of Xib's or Storyboards.

***
## About This Project: 
- **Why did I make Tasks?** I wanted a to-do list application that made it easier to stay on top of my tasks (don't we all?). I wanted the ability to add items to my calendar which would help me avoid snoozing items until I forgot about them. I also built this application to become more familiar with both the Core Data and CloudKit frameworks.  

- **What have I learned so far?** With this update I refactored almost the entire application to better reflect what I've learned as a developer since I first released Tasks.
  * I have gained a greater understanding of planning out the App architecture and basic functionality from the start! 
  * I used programatic UI that helped me conform to MVC. 
  * Implemented a protocol for my Core Data database to abstract database functionality to the protocol. 
  Used a 
  * Moved my Core Data stack to a framework to access the stack from my main application and the today widget.

- **Whats Next?** 
  * Planning for adding some additional features to Tasks.
  * Continue to improve code.

***
## Screenshots:
![Tasks List Added](Images/ListAddedGitHub_Dark.png) ![Tasks With Items Showing](Images/ItemsShowingGitHub_Dark.png)![Tasks Adding A Reminder](Images/SetReminderGitHub_Dark.png) ![Tasks Adding To Calendar](Images/AddToCalendarGitHub_Dark.png) ![Tasks Reminders Added](Images/ReminderAddedGitHub_Dark.png) 

[![Download on App Store](Images/AppStoreBlackGithub.png)](https://itunes.apple.com/us/app/tasks/id1378039351?mt=8)
***
## Requirements:
* iOS 13.0+
* Xcode 10+
***
## About The Developer:
I am an iOS Developer from Northern CA. I focus on writing applications in Swift and Objective-C. To learn more about me, you can check out my [portfolio](https://dylanmccarthyios.com).
***
## *** Previous Version Screenshots: ***
Some images of the previous version of Tasks. Version 2.0 is a great improvement in UI and Performance over the previous version. 
![Tasks Home With Added List](Images/HomeWithListAddedGithub.png) ![Tasks With Items Added](Images/TasksListWithItemsGithub.png)![Tasks Adding Reminder](Images/TasksAddingReminderGithub.png) 


