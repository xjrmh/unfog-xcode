//
//  unfogApp.swift
//  unfog
//
//  Created by Li Zheng on 11/15/25.
//

import SwiftUI
import CoreData

@main
struct unfogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
