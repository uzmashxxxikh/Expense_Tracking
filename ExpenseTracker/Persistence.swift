//
//  Persistence.swift
//  ExpenseTracker
//
//  Core Data stack and preview data
//

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample categories for preview
        let categories = [
            ("Food", "fork.knife", "#34C759"),
            ("Transport", "car.fill", "#FF9500"),
            ("Bills", "bolt.fill", "#007AFF"),
            ("Groceries", "cart.fill", "#30B0C7"),
            ("Entertainment", "tv.fill", "#AF52DE"),
            ("Rent", "house.fill", "#FF3B30")
        ]
        
        var createdCategories: [Category] = []
        
        for (name, icon, color) in categories {
            let category = Category(context: viewContext)
            category.id = UUID()
            category.name = name
            category.iconName = icon
            category.colorHex = color
            createdCategories.append(category)
        }
        
        // Create sample expenses
        let expenses = [
            ("Starbucks", 5.99, createdCategories[0]),
            ("Uber", 12.50, createdCategories[1]),
            ("Electricity Bill", 89.99, createdCategories[2]),
            ("Whole Foods", 45.67, createdCategories[3]),
            ("Netflix", 15.99, createdCategories[4])
        ]
        
        for (merchant, amount, category) in expenses {
            let expense = Expense(context: viewContext)
            expense.id = UUID()
            expense.merchantName = merchant
            expense.amount = amount
            expense.date = Date().addingTimeInterval(-Double.random(in: 0...604800)) // Random date within last week
            expense.category = category
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ExpenseTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Seed default categories if none exist
        seedDefaultCategoriesIfNeeded()
    }
    
    private func seedDefaultCategoriesIfNeeded() {
        let context = container.viewContext
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                // Create default categories
                let defaultCategories = [
                    ("Food", "fork.knife", "#34C759"),
                    ("Transport", "car.fill", "#FF9500"),
                    ("Bills", "bolt.fill", "#007AFF"),
                    ("Groceries", "cart.fill", "#30B0C7"),
                    ("Entertainment", "tv.fill", "#AF52DE"),
                    ("Rent", "house.fill", "#FF3B30")
                ]
                
                for (name, icon, color) in defaultCategories {
                    let category = Category(context: context)
                    category.id = UUID()
                    category.name = name
                    category.iconName = icon
                    category.colorHex = color
                }
                
                try context.save()
            }
        } catch {
            print("Failed to seed default categories: \(error)")
        }
    }
}
