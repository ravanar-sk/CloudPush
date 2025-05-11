//
//  APNSJWTToken.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 28/04/25.
//

import Foundation
import SwiftData

@Model
class APNSJWTToken {
    
    #Unique<APNSJWTToken>([\.keyID, \.teamID, \.p8])
    
    var keyID: String
    var teamID: String
    var p8: Data
    var token: String
    
    init(keyID: String, teamID: String, p8: Data, token: String) {
        self.keyID = keyID
        self.teamID = teamID
        self.p8 = p8
        self.token = token
    }
}
