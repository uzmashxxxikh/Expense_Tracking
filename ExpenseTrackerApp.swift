//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Main app entry point - Converted from Flutter/Dart main.dart
//

import CoreData
import SwiftUI

@main
struct ExpenseTrackerApp: App {
    private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

