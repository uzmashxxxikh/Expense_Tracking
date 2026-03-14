# Component Files

## 3.3 Add Files to Components Group

**Right-click "Components" group → New File → Swift File**

### 3.3.1 TotalSpentCard.swift

```swift
//
//  TotalSpentCard.swift
//  ExpenseTracker
//
//  Card component showing total spent amount
//

import SwiftUI

struct TotalSpentCard: View {
    let total: Double
    
    private var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Spent This Month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(formattedTotal)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(hex: "#007AFF")?.opacity(0.1) ?? Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack(spacing: 16) {
        TotalSpentCard(total: 1234.56)
        TotalSpentCard(total: 0.0)
        TotalSpentCard(total: 999999.99)
    }
    .padding()
}
```

### 3.3.2 DonutChartView.swift

```swift
//
//  DonutChartView.swift
//  ExpenseTracker
//
//  Interactive donut chart for expense categories
//

import SwiftUI
import Charts

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
                .chartAngleSelection(value: .constant(nil))
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
                
                // Category legend
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(categoryTotals.prefix(6), id: \.category.objectID) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 12, height: 12)
                            
                            Text(item.category.name)
                                .font(.caption)
                                .lineLimit(1)
                            
                            Spacer()
                            
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
```

### 3.3.3 RecentActivityList.swift

```swift
//
//  RecentActivityList.swift
//  ExpenseTracker
//
//  List component showing recent expense activity
//

import SwiftUI

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
```

### 3.3.4 ExpenseRow.swift

```swift
//
//  ExpenseRow.swift
//  ExpenseTracker
//
//  Individual expense row component
//

import SwiftUI

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
```