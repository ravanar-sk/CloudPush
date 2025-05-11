//
//  CloudPushApp.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 02/04/25.
//

import SwiftUI
import SwiftData

@main
struct CloudPushApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            APNSJWTToken.self,
//            APNSHistory.self
////            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 600, height: 600)
    }
}
