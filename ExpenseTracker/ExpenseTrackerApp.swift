//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Uzma Shaikh on 2026-03-14.


import SwiftUI
import CoreData

@main
struct ExpenseTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
