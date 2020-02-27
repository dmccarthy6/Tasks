//
//  ArrayExtension.swift
//  Tasks
//
//  Created by Dylan  on 1/22/20.
//  Copyright © 2020 Dylan . All rights reserved.
//



extension Array {
    
    /* */
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index <= endIndex else {
            return nil
        }
        return self[index]
    }
    
    
}
