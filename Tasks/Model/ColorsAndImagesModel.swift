//
//  ColorsAndImagesModel.swift
//  Tasks
//
//  Created by Dylan  on 1/3/20.
//  Copyright © 2020 Dylan . All rights reserved.
//

import Foundation
import UIKit

struct ColorSelector: Hashable {
    let id = UUID().uuidString
    let color: UIColor
    
    
    static func == (lhs: ColorSelector, rhs: ColorSelector) -> Bool {
        return lhs.id == rhs.id
    }
    
}

struct IconSelector: Hashable {
    let id = UUID().uuidString
    let icon: UIImage
    
    static func == (lhs: IconSelector, rhs: IconSelector) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension ColorSelector {
    
    static var Colors: [ColorSelector] {
        return [
            ColorSelector(color: ColorsForSelector.systemGreen),
            ColorSelector(color: ColorsForSelector.systemBlue),
            ColorSelector(color: ColorsForSelector.systemRed),
            ColorSelector(color: ColorsForSelector.systemGray),
            ColorSelector(color: ColorsForSelector.systemPink),
            ColorSelector(color: ColorsForSelector.systemTeal),
            ColorSelector(color: ColorsForSelector.systemIndigo),
            ColorSelector(color: ColorsForSelector.systemOrange),
            ColorSelector(color: ColorsForSelector.systemPurple),
            ColorSelector(color: ColorsForSelector.systemYellow)
        ]
    }
    
}

extension IconSelector {
    static var Icons: [IconSelector] {
        return [
            IconSelector(icon: ListIcons.airplane!),
            IconSelector(icon: ListIcons.bandageFill!),
            IconSelector(icon: ListIcons.boltCircle!),
            IconSelector(icon: ListIcons.carFill!),
            IconSelector(icon: ListIcons.cartFill!),
            IconSelector(icon: ListIcons.envelopeCircle!),
            IconSelector(icon: ListIcons.linkCircle!),
            IconSelector(icon: ListIcons.listDash!),
            IconSelector(icon: ListIcons.mapPinCircle!),
            IconSelector(icon: ListIcons.moonCircle!),
            IconSelector(icon: ListIcons.personCircle!),
            IconSelector(icon: ListIcons.phoneCircle!)
        ]
    }
}
