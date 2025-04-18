//
//  APNS.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import Foundation

@frozen
public enum APNSOSType:String, CaseIterable {
    case iOS
    case iPadOS
    case macOS
    case watchOS
    case tvOS
}

@frozen
public enum APNSPushType: String, CaseIterable {
    case alert
    case background
    case controls
    case location
    case voip
    case complication
    case fileProvider = "fileprovider"
    case mdm
    case liveActivity = "liveactivity"
    case pushToTalk = "pushtotalk"
}

@frozen
public enum APNSAuthFileType: String, CaseIterable {
    case p8
    case p12
}

@frozen
public enum APNSPriority: String, CaseIterable {
    case _10 = "10"
    case _5 = "5"
    case _1 = "1"
}

//struct APNS {
//    
//}

typealias APNS = Dictionary<APNSOSType, Dictionary<APNSPushType, APNSPushBase>>

protocol APNSPushBase {
    var bundleIDSuffix: String { get }
    var priority: [APNSPriority] { get }
}

struct APNSAlert: APNSPushBase {
    let bundleIDSuffix: String = ""
    let priority: [APNSPriority] = [._10 ,._5, ._1]
}

struct APNSBackground: APNSPushBase {
    let bundleIDSuffix: String = ""
    let priority: [APNSPriority] = [._5, ._1]
}

struct APNSLocation: APNSPushBase {
    let bundleIDSuffix: String = ".location-query"
    let priority: [APNSPriority] = [._10 ,._5]
}

struct APNSVoip: APNSPushBase {
    let bundleIDSuffix: String = ".voip"
    let priority: [APNSPriority] = [._10]
}

struct APNSComplication: APNSPushBase {
    let bundleIDSuffix: String = ".complication"
    let priority: [APNSPriority] = [._10]
}

struct APNSFileProvider: APNSPushBase {
    let bundleIDSuffix: String = ".pushkit.fileprovider"
    let priority: [APNSPriority] = [._10]
}

struct APNSMDM: APNSPushBase {
    let bundleIDSuffix: String = ""
    let priority: [APNSPriority] = [._10]
}

struct APNSLiveActivity: APNSPushBase {
    let bundleIDSuffix: String = ".push-type.liveactivity"
    let priority: [APNSPriority] = [._10]
}

struct APNSPushToTalk: APNSPushBase {
    let bundleIDSuffix: String = ".voip-ptt"
    let priority: [APNSPriority] = [._10]
}


let apns: APNS = [
    .iOS : [
        .alert: APNSAlert(),
        .background: APNSBackground(),
        .location: APNSLocation(),
        .voip: APNSVoip(),
        .complication: APNSComplication(),
        .fileProvider: APNSFileProvider(),
        .mdm: APNSMDM(),
        .liveActivity: APNSLiveActivity(),
        .pushToTalk: APNSPushToTalk()
    ],
    .iPadOS : [
        .alert: APNSAlert(),
        .background: APNSBackground(),
        .location: APNSLocation(),
        .voip: APNSVoip(),
        .fileProvider: APNSFileProvider(),
        .mdm: APNSMDM(),
        .liveActivity: APNSLiveActivity(),
        .pushToTalk: APNSPushToTalk()
    ],
    .macOS : [
        .alert: APNSAlert(),
        .background: APNSBackground(),
        .voip: APNSVoip(),
        .fileProvider: APNSFileProvider(),
        .mdm: APNSMDM(),

    ],
    .watchOS : [
        .complication: APNSComplication(),
    ],
    .tvOS : [
        .alert: APNSAlert(),
        .background: APNSBackground(),
        .voip: APNSVoip(),
        .fileProvider: APNSFileProvider(),
        .mdm: APNSMDM(),
    ],
]


struct APNSJSONPayload: Codable {
    
}


let defaultAPNSJSONPayload = [
    "aps": [
        "alert": "Hello World!",
        "sound": "default"
    ]
]
