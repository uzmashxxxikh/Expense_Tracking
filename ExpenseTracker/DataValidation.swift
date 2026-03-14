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
        
       
        if calendar.compare(date, to: Date(), toGranularity: .day) == .orderedDescending {
            return (false, "Expense date cannot be in the future")
        }
        
        
        if let tenYearsAgo = calendar.date(byAdding: .year, value: -10, to: Date()),
           date < tenYearsAgo {
            return (false, "Expense date cannot be more than 10 years ago")
        }
        
        return (true, nil)
    }
}
