//
//  SDCoordinator.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 09/05/25.
//

import Foundation
import SwiftData

class SDCoordinator {
    
    private static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            APNSJWTToken.self,
            APNSHistory.self
//            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    static let shared = ModelContext(sharedModelContainer)
    
}
