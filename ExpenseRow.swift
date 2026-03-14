//
//  ExpenseRow.swift
//  ExpenseTracker
//
//  Converted from expense_row.dart
//

import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    
    private var category: Category? {
        expense.category
    }
    
    private var merchantText: String {
        expense.merchantName
    }
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(category?.color ?? (Color(hex: "#007AFF") ?? .blue))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: category?.iconName ?? "tag.fill")
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(merchantText)
                    .font(.headline)
                
                Text(category?.name ?? "Uncategorized")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.body)
                .fontWeight(.bold)
                .foregroundStyle(.red)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        List {}
    }
}

