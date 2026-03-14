//
//  RecentActivityList.swift
//  ExpenseTracker
//
//  List component showing recent expense activity
//

import SwiftUI
import CoreData

struct RecentActivityList: View {
    let expenses: [Expense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
            
            if expenses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(expenses) { expense in
                        ExpenseRow(expense: expense)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return RecentActivityList(expenses: [])
        .environment(\.managedObjectContext, context)
        .padding()
}