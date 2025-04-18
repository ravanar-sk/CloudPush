//
//  Item.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 02/04/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
