import SwiftUI
import Charts

struct DonutChartView: View {
    let expenses: [Expense]
    @State private var selectedCategory: Category?
    
    private struct CategorySlice: Identifiable {
        let id = UUID()
        let category: Category
        let amount: Double
        let percentage: Double
    }
    
    private var slices: [CategorySlice] {
        var totals: [Category: Double] = [:]
        for expense in expenses {
            if let category = expense.category {
                totals[category, default: 0] += expense.amount
            }
        }
        let total = totals.values.reduce(0, +)
        return totals
            .map { CategorySlice(category: $0.key, amount: $0.value, percentage: total > 0 ? ($0.value / total) * 100 : 0) }
            .sorted { $0.amount > $1.amount }
    }
    
    private var total: Double {
        slices.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
            
            if total > 0 {
                Chart(slices) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(item.category.color)
                    .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.4)
                    .cornerRadius(4)
                }
                .frame(height: 220)
                .onTapGesture { location in
                    // Simple tap handling - cycle through categories
                    if let current = selectedCategory,
                       let currentIndex = slices.firstIndex(where: { $0.category == current }) {
                        let nextIndex = (currentIndex + 1) % slices.count
                        selectedCategory = slices[nextIndex].category
                    } else {
                        selectedCategory = slices.first?.category
                    }
                }
                
                if let selected = selectedCategory,
                   let slice = slices.first(where: { $0.category == selected }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Circle()
                                .fill(selected.color)
                                .frame(width: 12, height: 12)
                            Text(selected.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        Text("$\(slice.amount, specifier: "%.2f") • \(slice.percentage, specifier: "%.1f")%")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text("Tap chart to see category details")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(slices) { item in
                            Button {
                                selectedCategory = selectedCategory == item.category ? nil : item.category
                            } label: {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(item.category.color)
                                        .frame(width: 10, height: 10)
                                    Text(item.category.name)
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                    Text("\(item.percentage, specifier: "%.1f")%")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedCategory == item.category ? item.category.color.opacity(0.2) : Color(.secondarySystemGroupedBackground))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No expenses this month")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DonutChartView(expenses: [])
}

