//
//  Category+CoreData.swift
//  ExpenseTracker
//
//  Core Data model extension for Category entity
//  Benjamin Antolin

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