//
//  Endpoint.swift
//  TasksFramework
//
//  Created by Dylan  on 2/10/20.
//  Copyright © 2020 Dylan . All rights reserved.
//

import Foundation


protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
}

extension Endpoint {
    
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.path = path
        components.host = host
        
        return components
    }
}
