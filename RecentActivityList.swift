//
//  RecentActivityList.swift
//  ExpenseTracker
//
//  Converted from recent_activity_list.dart
//

import SwiftUI
import CoreData

struct RecentActivityList: View {
    let expenses: [Expense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Activity")
                .font(.headline)
            
            if expenses.isEmpty {
                Text("No recent expenses")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(expenses) { expense in
                        ExpenseRow(expense: expense)
                        
                        if expense.id != expenses.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
    }
}

#Preview {
    RecentActivityList(expenses: [])
        .padding()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
