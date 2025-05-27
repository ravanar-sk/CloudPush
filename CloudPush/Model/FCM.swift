//
//  FCM.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import Foundation

struct FCM {
    
}

public enum FCMPushDestinations: String, CaseIterable {
    case device = "Device Token"
    case topic = "Topic"
//    case multipleDevices = "Multiple Devices"
}

let defaultFCMJSONPayload = [
    "notification": [
        "title": "Hello",
        "body": "Hey there"
    ]
]
