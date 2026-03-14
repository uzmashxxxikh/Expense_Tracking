//
//  ExpenseViewModel.swift
//  ExpenseTracker
//
//  MVVM ViewModel for managing expenses and categories
//

import Combine
import CoreData
import Foundation

/// Optional shared helper for computed queries on top of Core Data.
final class ExpenseViewModel: ObservableObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Convenience Fetches

    func expenses(inMonthOf date: Date) -> [Expense] {
        let calendar = Calendar.current
        guard let range = calendar.dateInterval(of: .month, for: date) else { return [] }
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", range.start as NSDate, range.end as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func totalSpent(inMonthOf date: Date) -> Double {
        expenses(inMonthOf: date).reduce(0) { $0 + $1.amount }
    }

    func recentExpenses(limit: Int = 5) -> [Expense] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = limit
        return (try? context.fetch(request)) ?? []
    }

    func totalsByCategory(for expenses: [Expense]) -> [(Category, Double)] {
        var totals: [Category: Double] = [:]
        for expense in expenses {
            if let category = expense.category {
                totals[category, default: 0] += expense.amount
            }
        }
        return totals.sorted { $0.value > $1.value }
    }

    func searchExpenses(query: String, category: Category? = nil) -> [Expense] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        var predicates: [NSPredicate] = []

        if !query.isEmpty {
            predicates.append(NSPredicate(format: "merchantName CONTAINS[cd] %@", query))
        }
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func expensesByDateRange(from startDate: Date, to endDate: Date) -> [Expense] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func totalSpentByCategory(_ category: Category) -> Double {
        guard let expenses = category.expenses as? Set<Expense> else { return 0 }
        return expenses.reduce(0) { $0 + $1.amount }
    }
}

