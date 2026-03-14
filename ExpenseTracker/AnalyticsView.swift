//
//  AnalyticsView.swift
//  ExpenseTracker
//
//  Analytics and statistics view with charts
//

import SwiftUI
import Charts
import CoreData

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .easeInOut
    )
    private var expenses: FetchedResults<Expense>
    
    @State private var selectedCategory: Category?
    
    private var totalAllTime: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    private var averagePerMonth: Double {
        guard !expenses.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedExpenses = expenses.sorted { $0.date < $1.date }
        
        guard let firstDate = sortedExpenses.first?.date,
              let lastDate = sortedExpenses.last?.date else {
            return 0
        }
        
        let components = calendar.dateComponents([.month], from: firstDate, to: lastDate)
        let monthCount = max((components.month ?? 0) + 1, 1)
        
        return totalAllTime / Double(monthCount)
    }
    
    private var categoryTotals: [(category: Category, amount: Double)] {
        var totals: [Category: Double] = [:]
        for expense in expenses {
            if let category = expense.category {
                totals[category, default: 0] += expense.amount
            }
        }
        return totals.sorted { $0.value > $1.value }.map { (category: $0.key, amount: $0.value) }
    }
    
    private var currencyFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }
    
    private func formatted(_ amount: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Total all-time and average
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Spent (All Time)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(formatted(totalAllTime))
                            .font(.system(size: 36, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Average Per Month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(formatted(averagePerMonth))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Pie chart
                if !categoryTotals.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spending by Category")
                            .font(.headline)
                        
                        Chart(categoryTotals, id: \.category.objectID) { item in
                            SectorMark(
                                angle: .value("Amount", item.amount),
                                innerRadius: .ratio(0.6),
                                angularInset: 2
                            )
                            .foregroundStyle(item.category.color)
                            .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.4)
                            .cornerRadius(4)
                        }
                        .frame(height: 260)
                        .chartLegend(.hidden)
                        .onTapGesture { location in
                            // Simple tap handling - cycle through categories
                            if let current = selectedCategory,
                               let currentIndex = categoryTotals.firstIndex(where: { $0.category == current }) {
                                let nextIndex = (currentIndex + 1) % categoryTotals.count
                                selectedCategory = categoryTotals[nextIndex].category
                            } else {
                                selectedCategory = categoryTotals.first?.category
                            }
                        }
                        
                        if let selected = selectedCategory,
                           let entry = categoryTotals.first(where: { $0.category == selected }) {
                            let percentage = totalAllTime > 0 ? (entry.amount / totalAllTime) * 100 : 0
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Circle()
                                        .fill(selected.color)
                                        .frame(width: 12, height: 12)
                                    Text(selected.name)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                Text("\(formatted(entry.amount)) • \(String(format: "%.1f", percentage))%")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Text("Tap chart segments to see details")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Category list
                if !categoryTotals.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category Breakdown")
                            .font(.headline)
                        
                        ForEach(categoryTotals, id: \.category.objectID) { item in
                            Button {
                                selectedCategory = selectedCategory == item.category ? nil : item.category
                            } label: {
                                CategoryBreakdownRow(
                                    category: item.category,
                                    amount: item.amount,
                                    total: totalAllTime,
                                    isSelected: selectedCategory == item.category
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct CategoryBreakdownRow: View {
    let category: Category
    let amount: Double
    let total: Double
    let isSelected: Bool
    
    private var percentage: Double {
        total > 0 ? (amount / total) * 100 : 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 12) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: category.iconName)
                                .foregroundStyle(.white)
                        }
                        .overlay {
                            if isSelected {
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                                Circle()
                                    .stroke(category.color, lineWidth: 2)
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.subheadline)
                            .fontWeight(isSelected ? .semibold : .medium)
                        
                        Text("\(String(format: "%.1f", percentage))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer(minLength: 8)
                    
                    Text(String(format: "$%.2f", amount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                    .fontWeight(isSelected ? .bold : .semibold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .clipShape(Capsule())
                    
                    Rectangle()
                        .fill(category.color)
                        .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 6)
                        .clipShape(Capsule())
                        .opacity(isSelected ? 1.0 : 0.8)
                }
            }
            .frame(height: 6)
        }
        .padding(isSelected ? 12 : 8)
        .background(isSelected ? category.color.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        AnalyticsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}