# Model and Utility Files

## 3.4 Add Files to Models Group

**Right-click "Models" group → New File → Swift File**

### 3.4.1 Expense+CoreData.swift

```swift
//
//  Expense+CoreData.swift
//  ExpenseTracker
//
//  Core Data model extension for Expense entity
//

import CoreData
import Foundation

@objc(Expense)
public class Expense: NSManagedObject, Identifiable {
}

extension Expense {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var merchantName: String
    @NSManaged public var date: Date
    @NSManaged public var category: Category?
}

// MARK: - Computed Properties
extension Expense {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
```

### 3.4.2 Category+CoreData.swift

```swift
//
//  Category+CoreData.swift
//  ExpenseTracker
//
//  Core Data model extension for Category entity
//

import CoreData
import Foundation
import SwiftUI

@objc(Category)
public class Category: NSManagedObject, Identifiable {
}

extension Category {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var iconName: String
    @NSManaged public var colorHex: String
    @NSManaged public var expenses: NSSet?
}

// MARK: Generated accessors for expenses
extension Category {
    @objc(addExpensesObject:)
    @NSManaged public func addToExpenses(_ value: Expense)

    @objc(removeExpensesObject:)
    @NSManaged public func removeFromExpenses(_ value: Expense)

    @objc(addExpenses:)
    @NSManaged public func addToExpenses(_ values: NSSet)

    @objc(removeExpenses:)
    @NSManaged public func removeFromExpenses(_ values: NSSet)
}

// MARK: - Computed Properties
extension Category {
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
    
    var expenseCount: Int {
        (expenses as? Set<Expense>)?.count ?? 0
    }
    
    var totalAmount: Double {
        guard let expenses = expenses as? Set<Expense> else { return 0 }
        return expenses.reduce(0) { $0 + $1.amount }
    }
}
```

### 3.4.3 ExpenseViewModel.swift

```swift
//
//  ExpenseViewModel.swift
//  ExpenseTracker
//
//  View model for expense-related data operations
//

import Foundation
import CoreData
import SwiftUI

class ExpenseViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Expense Operations
    
    func createExpense(
        amount: Double,
        merchantName: String,
        date: Date,
        category: Category
    ) throws {
        let expense = Expense(context: context)
        expense.id = UUID()
        expense.amount = amount
        expense.merchantName = merchantName
        expense.date = date
        expense.category = category
        
        try context.save()
    }
    
    func updateExpense(
        _ expense: Expense,
        amount: Double,
        merchantName: String,
        date: Date,
        category: Category
    ) throws {
        expense.amount = amount
        expense.merchantName = merchantName
        expense.date = date
        expense.category = category
        
        try context.save()
    }
    
    func deleteExpense(_ expense: Expense) throws {
        context.delete(expense)
        try context.save()
    }
    
    // MARK: - Category Operations
    
    func createCategory(
        name: String,
        iconName: String,
        colorHex: String
    ) throws {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.iconName = iconName
        category.colorHex = colorHex
        
        try context.save()
    }
    
    func updateCategory(
        _ category: Category,
        name: String,
        iconName: String,
        colorHex: String
    ) throws {
        category.name = name
        category.iconName = iconName
        category.colorHex = colorHex
        
        try context.save()
    }
    
    func deleteCategory(_ category: Category) throws {
        // Delete all associated expenses
        if let expenses = category.expenses as? Set<Expense> {
            for expense in expenses {
                context.delete(expense)
            }
        }
        
        context.delete(category)
        try context.save()
    }
    
    // MARK: - Data Fetching
    
    func fetchExpenses(
        sortBy: ExpenseSortOption = .dateDescending,
        filterBy category: Category? = nil,
        searchText: String = ""
    ) -> [Expense] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        // Category filter
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        // Search filter
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "merchantName CONTAINS[cd] %@", searchText))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // Sort descriptor
        request.sortDescriptors = [sortBy.sortDescriptor]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch expenses: \(error)")
            return []
        }
    }
    
    func fetchCategories(sortBy: CategorySortOption = .nameAscending) -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [sortBy.sortDescriptor]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    // MARK: - Analytics
    
    func getTotalSpent(for period: TimePeriod = .allTime) -> Double {
        let expenses = getExpenses(for: period)
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    func getCategoryTotals(for period: TimePeriod = .allTime) -> [(Category, Double)] {
        let expenses = getExpenses(for: period)
        var totals: [Category: Double] = [:]
        
        for expense in expenses {
            if let category = expense.category {
                totals[category, default: 0] += expense.amount
            }
        }
        
        return totals.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }
    }
    
    private func getExpenses(for period: TimePeriod) -> [Expense] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        if let predicate = period.predicate {
            request.predicate = predicate
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch expenses for period: \(error)")
            return []
        }
    }
}

// MARK: - Supporting Types

enum ExpenseSortOption {
    case dateAscending
    case dateDescending
    case amountAscending
    case amountDescending
    case merchantAscending
    case merchantDescending
    
    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .dateAscending:
            return NSSortDescriptor(keyPath: \Expense.date, ascending: true)
        case .dateDescending:
            return NSSortDescriptor(keyPath: \Expense.date, ascending: false)
        case .amountAscending:
            return NSSortDescriptor(keyPath: \Expense.amount, ascending: true)
        case .amountDescending:
            return NSSortDescriptor(keyPath: \Expense.amount, ascending: false)
        case .merchantAscending:
            return NSSortDescriptor(keyPath: \Expense.merchantName, ascending: true)
        case .merchantDescending:
            return NSSortDescriptor(keyPath: \Expense.merchantName, ascending: false)
        }
    }
}

enum CategorySortOption {
    case nameAscending
    case nameDescending
    case expenseCountAscending
    case expenseCountDescending
    
    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .nameAscending:
            return NSSortDescriptor(keyPath: \Category.name, ascending: true)
        case .nameDescending:
            return NSSortDescriptor(keyPath: \Category.name, ascending: false)
        case .expenseCountAscending:
            return NSSortDescriptor(keyPath: \Category.expenses.@count, ascending: true)
        case .expenseCountDescending:
            return NSSortDescriptor(keyPath: \Category.expenses.@count, ascending: false)
        }
    }
}

enum TimePeriod {
    case today
    case thisWeek
    case thisMonth
    case thisYear
    case allTime
    
    var predicate: NSPredicate? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
            
        case .thisWeek:
            guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return nil }
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
            return NSPredicate(format: "date >= %@ AND date < %@", startOfWeek as NSDate, endOfWeek as NSDate)
            
        case .thisMonth:
            guard let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start else { return nil }
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            return NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as NSDate, endOfMonth as NSDate)
            
        case .thisYear:
            guard let startOfYear = calendar.dateInterval(of: .year, for: now)?.start else { return nil }
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
            return NSPredicate(format: "date >= %@ AND date < %@", startOfYear as NSDate, endOfYear as NSDate)
            
        case .allTime:
            return nil
        }
    }
}
```

## 3.5 Add Files to Utilities Group

**Right-click "Utilities" group → New File → Swift File**

### 3.5.1 DataValidation.swift

```swift
//
//  DataValidation.swift
//  ExpenseTracker
//
//  Data validation utilities for the expense tracker
//

import Foundation

struct DataValidation {
    
    /// Validates an expense amount
    static func validateAmount(_ amountString: String) -> (isValid: Bool, amount: Double?, error: String?) {
        let trimmed = amountString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return (false, nil, "Please enter an amount")
        }
        
        guard let amount = Double(trimmed) else {
            return (false, nil, "Please enter a valid number")
        }
        
        guard amount > 0 else {
            return (false, nil, "Amount must be greater than $0.00")
        }
        
        guard amount <= 999999.99 else {
            return (false, nil, "Amount cannot exceed $999,999.99")
        }
        
        return (true, amount, nil)
    }
    
    /// Validates a merchant name
    static func validateMerchantName(_ name: String) -> (isValid: Bool, error: String?) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return (false, "Please enter a merchant or item name")
        }
        
        guard trimmed.count <= 100 else {
            return (false, "Merchant name must be 100 characters or less")
        }
        
        return (true, nil)
    }
    
    /// Validates a category name
    static func validateCategoryName(_ name: String, existingNames: [String] = []) -> (isValid: Bool, error: String?) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return (false, "Category name is required")
        }
        
        guard trimmed.count <= 50 else {
            return (false, "Category name must be 50 characters or less")
        }
        
        let lowercasedName = trimmed.lowercased()
        if existingNames.contains(where: { $0.lowercased() == lowercasedName }) {
            return (false, "Category name already exists")
        }
        
        return (true, nil)
    }
    
    /// Validates an expense date
    static func validateExpenseDate(_ date: Date) -> (isValid: Bool, error: String?) {
        let calendar = Calendar.current
        
        // Check if date is in the future
        if calendar.compare(date, to: Date(), toGranularity: .day) == .orderedDescending {
            return (false, "Expense date cannot be in the future")
        }
        
        // Check if date is too far in the past (more than 10 years)
        if let tenYearsAgo = calendar.date(byAdding: .year, value: -10, to: Date()),
           date < tenYearsAgo {
            return (false, "Expense date cannot be more than 10 years ago")
        }
        
        return (true, nil)
    }
}
```

### 3.5.2 Color+Hex.swift

```swift
//
//  Color+Hex.swift
//  ExpenseTracker
//
//  Color utilities for hex conversion
//

import SwiftUI

extension Color {
    /// Initialize Color from hex string
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to hex string
    var toHex: String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

// MARK: - Predefined Colors
extension Color {
    static let expenseRed = Color(hex: "#FF3B30") ?? .red
    static let categoryBlue = Color(hex: "#007AFF") ?? .blue
    static let categoryGreen = Color(hex: "#34C759") ?? .green
    static let categoryOrange = Color(hex: "#FF9500") ?? .orange
    static let categoryPurple = Color(hex: "#AF52DE") ?? .purple
    static let categoryTeal = Color(hex: "#30B0C7") ?? .teal
}
```