//
//  Push.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import Foundation

protocol Push {
    var body: [String:String] {get}
    var title: String {get}
    var message: String {get}
    
}
