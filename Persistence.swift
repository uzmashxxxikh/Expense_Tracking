import CoreData
import SwiftUI

/// Core Data stack for the ExpenseTracker app.
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = PersistenceController.buildManagedObjectModel()
        container = NSPersistentContainer(name: "ExpenseTracker", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true

        seedDefaultCategoriesIfNeeded(context: container.viewContext)
    }

    // MARK: - Programmatic Core Data Model (avoids needing a .xcdatamodeld file)

    private static func buildManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let categoryEntity = NSEntityDescription()
        categoryEntity.name = "Category"
        categoryEntity.managedObjectClassName = "Category"

        let categoryId = NSAttributeDescription()
        categoryId.name = "id"
        categoryId.attributeType = .UUIDAttributeType
        categoryId.isOptional = false
        let categoryName = NSAttributeDescription()
        categoryName.name = "name"
        categoryName.attributeType = .stringAttributeType
        categoryName.isOptional = false
        let categoryIconName = NSAttributeDescription()
        categoryIconName.name = "iconName"
        categoryIconName.attributeType = .stringAttributeType
        categoryIconName.isOptional = false
        let categoryColorHex = NSAttributeDescription()
        categoryColorHex.name = "colorHex"
        categoryColorHex.attributeType = .stringAttributeType
        categoryColorHex.isOptional = false

        let expenseEntity = NSEntityDescription()
        expenseEntity.name = "Expense"
        expenseEntity.managedObjectClassName = "Expense"

        let expenseId = NSAttributeDescription()
        expenseId.name = "id"
        expenseId.attributeType = .UUIDAttributeType
        expenseId.isOptional = false
        let expenseAmount = NSAttributeDescription()
        expenseAmount.name = "amount"
        expenseAmount.attributeType = .doubleAttributeType
        expenseAmount.defaultValue = 0.0
        let expenseMerchantName = NSAttributeDescription()
        expenseMerchantName.name = "merchantName"
        expenseMerchantName.attributeType = .stringAttributeType
        expenseMerchantName.isOptional = false
        let expenseDate = NSAttributeDescription()
        expenseDate.name = "date"
        expenseDate.attributeType = .dateAttributeType
        expenseDate.isOptional = false

        let categoryToExpenses = NSRelationshipDescription()
        categoryToExpenses.name = "expenses"
        categoryToExpenses.maxCount = 0
        categoryToExpenses.deleteRule = .nullifyDeleteRule

        let expenseToCategory = NSRelationshipDescription()
        expenseToCategory.name = "category"
        expenseToCategory.maxCount = 1
        expenseToCategory.isOptional = true
        expenseToCategory.deleteRule = .nullifyDeleteRule

        categoryToExpenses.destinationEntity = expenseEntity
        expenseToCategory.destinationEntity = categoryEntity
        categoryToExpenses.inverseRelationship = expenseToCategory
        expenseToCategory.inverseRelationship = categoryToExpenses

        categoryEntity.properties = [categoryId, categoryName, categoryIconName, categoryColorHex, categoryToExpenses]
        expenseEntity.properties = [expenseId, expenseAmount, expenseMerchantName, expenseDate, expenseToCategory]

        model.entities = [categoryEntity, expenseEntity]
        return model
    }

    // MARK: - Preview

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Seed preview categories and a few expenses
        let categories = Self.defaultCategories(in: context)

        let calendar = Calendar.current
        let now = Date()

        func makeExpense(amount: Double, merchant: String, daysAgo: Int, category: Category) {
            let expense = Expense(context: context)
            expense.id = UUID()
            expense.amount = amount
            expense.merchantName = merchant
            expense.date = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            expense.category = category
        }

        if let food = categories.first(where: { $0.name == "Food" }) {
            makeExpense(amount: 45.20, merchant: "Restaurant Dinner", daysAgo: 0, category: food)
        }

        if let transport = categories.first(where: { $0.name == "Transport" }) {
            makeExpense(amount: 12.50, merchant: "Uber Ride", daysAgo: 0, category: transport)
        }

        if let bills = categories.first(where: { $0.name == "Bills" }) {
            makeExpense(amount: 120.0, merchant: "Electricity Bill", daysAgo: 1, category: bills)
        }

        do {
            try context.save()
        } catch {
            fatalError("Failed to seed preview data: \(error)")
        }

        return controller
    }()

    // MARK: - Seeding

    private func seedDefaultCategoriesIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.fetchLimit = 1

        if let count = try? context.count(for: request), count > 0 {
            return
        }

        _ = Self.defaultCategories(in: context)

        do {
            try context.save()
        } catch {
            print("Failed to seed default categories: \(error)")
        }
    }

    @discardableResult
    private static func defaultCategories(in context: NSManagedObjectContext) -> [Category] {
        let defaults: [(name: String, hex: String, icon: String)] = [
            ("Food", "#34C759", "fork.knife"),
            ("Transport", "#FF9500", "car.fill"),
            ("Bills", "#007AFF", "doc.text.fill"),
            ("Groceries", "#30B0C7", "cart.fill"),
            ("Entertainment", "#AF52DE", "tv.fill"),
            ("Rent", "#FF3B30", "house.fill")
        ]

        var categories: [Category] = []

        for item in defaults {
            let category = Category(context: context)
            category.id = UUID()
            category.name = item.name
            category.iconName = item.icon
            category.colorHex = item.hex
            categories.append(category)
        }

        return categories
    }
}

