//
//  APNSHistory.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 29/04/25.
//

import Foundation
import SwiftData

@Model
class APNSHistory {
    
    #Unique<APNSHistory>([\.apnsId])
    
    var apnsId: String
    var status: String
    var apnsUniqueId: String
    var body: String
    
    init(apnsId: String, status: String, apnsUniqueId: String, body: String) {
        self.status = status
        self.apnsId = apnsId
        self.apnsUniqueId = apnsUniqueId
        self.body = body
    }
}
