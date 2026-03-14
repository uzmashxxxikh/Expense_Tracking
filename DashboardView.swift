//
//  DashboardView.swift
//  ExpenseTracker
//
//  Converted from dashboard_screen.dart
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var showingAddExpense = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .easeInOut
    )
    private var allExpenses: FetchedResults<Expense>
    
    private var currentMonthExpenses: [Expense] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
        return allExpenses.filter { $0.date >= interval.start && $0.date < interval.end }
    }
    
    private var totalThisMonth: Double {
        currentMonthExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var recentFive: [Expense] {
        Array(allExpenses.sorted(by: { $0.date > $1.date }).prefix(5))
    }
    
    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Overview")
                                .font(.title)
                                .fontWeight(.bold)
                            Text(monthYearTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    
                    TotalSpentCard(total: totalThisMonth)
                    
                    DonutChartView(expenses: currentMonthExpenses)
                    
                    RecentActivityList(expenses: recentFive)
                }
                .padding()
            }
            
            Button {
                showingAddExpense = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Quick Add")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#007AFF") ?? .blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .sheet(isPresented: $showingAddExpense) {
                AddEditExpenseView(existingExpense: nil)
                    .environment(\.managedObjectContext, context)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}