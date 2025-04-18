//
//  SideBarItem.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import Foundation

struct SideBarItem: Identifiable, Hashable {
    enum SideBarItemType {
    case apns
        case fcm
        
        func name() -> String {
            switch self {
            case .apns:
                return "APNS"
            case .fcm:
                return "FCM"
            }
        }
    }
    
    let id: UUID = UUID()
    let type: SideBarItemType
    
}
