//
//  ExpenseRow.swift
//  ExpenseTracker
//
//  Individual expense row component
//

import SwiftUI
import CoreData

struct ExpenseRow: View {
    let expense: Expense
    
    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: expense.amount)) ?? "$0.00"
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: expense.date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            if let category = expense.category {
                Circle()
                    .fill(category.color)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: category.iconName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    }
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "questionmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    }
            }
            
            // Expense Details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.merchantName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let category = expense.category {
                    Text(category.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Amount and Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let category = Category(context: context)
    category.name = "Food"
    category.iconName = "fork.knife"
    category.colorHex = "#34C759"
    
    let expense = Expense(context: context)
    expense.merchantName = "Starbucks"
    expense.amount = 5.99
    expense.date = Date()
    expense.category = category
    
    return ExpenseRow(expense: expense)
        .padding()
        .environment(\.managedObjectContext, context)
}