//
//  DonutChartView.swift
//  ExpenseTracker
//
//  Interactive donut chart for expense categories


import SwiftUI
import Charts
import CoreData

struct DonutChartView: View {
    let expenses: [Expense]
    @State private var selectedCategory: Category?
    
    private var categoryTotals: [(category: Category, amount: Double)] {
        var totals: [Category: Double] = [:]
        for expense in expenses {
            if let category = expense.category {
                totals[category, default: 0] += expense.amount
            }
        }
        return totals.sorted { $0.value > $1.value }.map { (category: $0.key, amount: $0.value) }
    }
    
    private var totalAmount: Double {
        categoryTotals.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Breakdown")
                .font(.headline)
            
            if categoryTotals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No expenses this month")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
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
                .frame(height: 200)
                .chartLegend(.hidden)
                .onTapGesture { location in
                    
                    if let current = selectedCategory,
                       let currentIndex = categoryTotals.firstIndex(where: { $0.category == current }) {
                        let nextIndex = (currentIndex + 1) % categoryTotals.count
                        selectedCategory = categoryTotals[nextIndex].category
                    } else {
                        selectedCategory = categoryTotals.first?.category
                    }
                }
                
                
                VStack(spacing: 8) {
                    ForEach(categoryTotals.prefix(6), id: \.category.objectID) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 12, height: 12)
                            
                            Text(item.category.name)
                                .font(.caption)
                                .lineLimit(1)
                            
                            Spacer(minLength: 4)
                            
                            Text(String(format: "$%.0f", item.amount))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.6)
                        .onTapGesture {
                            selectedCategory = selectedCategory == item.category ? nil : item.category
                        }
                    }
                }
                
                if let selected = selectedCategory,
                   let entry = categoryTotals.first(where: { $0.category == selected }) {
                    let percentage = totalAmount > 0 ? (entry.amount / totalAmount) * 100 : 0
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Circle()
                                .fill(selected.color)
                                .frame(width: 12, height: 12)
                            Text(selected.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        Text("\(String(format: "$%.2f", entry.amount)) • \(String(format: "%.1f", percentage))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
    return DonutChartView(expenses: [])
        .environment(\.managedObjectContext, context)
        .padding()
}
