//
//  ExpenseViewModel.swift
//  ExpenseTracker
//
//  View model for expense-related data operations
//

import Foundation
import CoreData
import SwiftUI
import Combine

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
            return NSSortDescriptor(key: "expenses.@count", ascending: true)
        case .expenseCountDescending:
            return NSSortDescriptor(key: "expenses.@count", ascending: false)
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