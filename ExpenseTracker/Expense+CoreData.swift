//
//  Expense+CoreData.swift
//  ExpenseTracker
//
//  Core Data model extension for Expense entity


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
