//
//  MainView.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import SwiftUI

struct MainView: View {
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    @State private var arraySideMenu: [SideBarItem] = [
        SideBarItem(type: .apns),
        SideBarItem(type: .fcm)
    ]
    
    @State private var selectedSideMenuItem: SideBarItem = SideBarItem(type: .apns)
    
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List($arraySideMenu, selection:$selectedSideMenuItem) { element in
                Button {
                    selectedSideMenuItem = element.wrappedValue
                } label: {
                    if (element.wrappedValue.type == selectedSideMenuItem.type) {
                        HStack {
                            Text(element.wrappedValue.type.name())
                            Spacer()
                            Color.white.mask(Circle()).frame(width: 5, height: 5)
                        }
                    } else {
                        Text(element.wrappedValue.type.name())
                        Spacer()
                    }
                }
                .buttonStyle(.accessoryBar)
            }
        } detail: {
            switch selectedSideMenuItem.type {
            case .apns:
                Group {
                    APNSView()
                    Spacer()
                }
                .padding()
                
            case .fcm:
                FCMView()
            }
        }
        .navigationTitle(selectedSideMenuItem.type.name())
    }
}
#Preview {
    MainView()
}
