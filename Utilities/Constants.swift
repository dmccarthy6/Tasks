//
//  Constants.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit

enum Colors {
    
    static let tasksRed = UIColor(red: 0.898, green: 0.2549, blue: 0.1922, alpha: 1)
    static let editItemRed = UIColor(red: 0.9882, green: 0.2941, blue: 0, alpha: 1.0)
    static let tasksYellow = UIColor(red: 1, green: 0.9804, blue: 0, alpha: 1.0)
    static let tasksGray = UIColor(red: 0.0235, green: 0.0275, blue: 0.0196, alpha: 1.0)
}

enum ColorsForSelector {
    static let systemGreen = UIColor.systemGreen
    static let systemBlue = UIColor.systemBlue
    static let systemRed = UIColor.systemRed
    static let systemGray = UIColor.systemGray
    static let systemPink = UIColor.systemPink
    static let systemTeal = UIColor.systemTeal
    static let systemIndigo = UIColor.systemIndigo
    static let systemOrange = UIColor.systemOrange
    static let systemPurple = UIColor.systemPurple
    static let systemYellow = UIColor.systemYellow
}
//enum Fonts { -- USING DYNAMIC, can delete this
//
//    static let AvenirLight =  UIFont(name: "Avenir Light", size: 18)
//    static let AvenirOblique = UIFont(name: "Avenir Oblique", size: 18)
//    static let AvenirHeavy = UIFont(name: "Avenir Heavy", size: 18)
//    static let LatoRegular = UIFont(name: "Lato Regular", size: 18)
//}


enum DynamicFonts {
    
    static let HeadlineDynamic = UIFont.preferredFont(forTextStyle: .headline)
    static let SubHeadlineDynamic = UIFont.preferredFont(forTextStyle: .subheadline)
    static let LargeTitleDynamic = UIFont.preferredFont(forTextStyle: .largeTitle)
    static let FootnoteDynamic = UIFont.preferredFont(forTextStyle: .footnote)
    static let BodyDynamic = UIFont.preferredFont(forTextStyle: .body)
    static let Title1Dynamic = UIFont.preferredFont(forTextStyle: .title1)
    static let Title2Dynamic = UIFont.preferredFont(forTextStyle: .title2)
    static let Title3Dynamic = UIFont.preferredFont(forTextStyle: .title3)
    
}
