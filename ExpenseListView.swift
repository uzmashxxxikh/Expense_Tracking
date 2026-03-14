//
//  ExpenseListView.swift
//  ExpenseTracker
//
//  Updated to match COMP3097 Project Proposal mockup
//

import SwiftUI
import CoreData

struct ExpenseListView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var searchText = ""
    @State private var selectedCategory: Category? = nil
    @State private var showingFilter = false
    @State private var showingAddExpense = false
    @State private var selectedExpense: Expense? = nil
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .easeInOut
    )
    private var expenses: FetchedResults<Expense>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .easeInOut
    )
    private var categories: FetchedResults<Category>
    
    private var filteredExpenses: [Expense] {
        expenses.filter { expense in
            let matchesSearch = searchText.isEmpty ||
            expense.merchantName.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil ||
            expense.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    private var groupedExpenses: [(String, [Expense])] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        
        var groups: [(String, [Expense])] = []
        
        let sorted = filteredExpenses.sorted { $0.date > $1.date }
        var buckets: [String: [Expense]] = [:]
        var order: [String] = []
        
        for expense in sorted {
            let label: String
            if calendar.isDateInToday(expense.date) {
                label = "Today"
            } else if calendar.isDateInYesterday(expense.date) {
                label = "Yesterday"
            } else {
                label = formatter.string(from: expense.date)
            }
            
            if buckets[label] == nil {
                order.append(label)
                buckets[label] = []
            }
            buckets[label]?.append(expense)
        }
        
        for key in order {
            if let list = buckets[key] {
                groups.append((key, list))
            }
        }
        
        return groups
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if groupedExpenses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text(searchText.isEmpty ? "No expenses yet" : "No expenses found")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        if !searchText.isEmpty {
                            Text("Try adjusting your search")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(groupedExpenses, id: \.0) { section in
                            Section {
                                ForEach(section.1) { expense in
                                    Button {
                                        selectedExpense = expense
                                        showingAddExpense = true
                                    } label: {
                                        ExpenseRow(expense: expense)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .onDelete { indexSet in
                                    delete(at: indexSet, in: section.1)
                                }
                            } header: {
                                Text(section.0)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                    .textCase(nil)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search by merchant name")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .disabled(categories.isEmpty)
                }
            }
            
            Button {
                selectedExpense = nil
                showingAddExpense = true
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(hex: "#007AFF") ?? .blue)
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }
            .padding(24)
        }
        .sheet(isPresented: $showingAddExpense) {
            AddEditExpenseView(existingExpense: selectedExpense)
                .environment(\.managedObjectContext, context)
        }
        }
        .sheet(isPresented: $showingFilter) {
            CategoryFilterSheet(
                categories: Array(categories),
                selectedCategory: $selectedCategory
            )
        }
    }
    
    private func delete(at offsets: IndexSet, in sectionExpenses: [Expense]) {
        for index in offsets {
            let expense = sectionExpenses[index]
            context.delete(expense)
        }
        try? context.save()
    }
}

struct CategoryFilterSheet: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    selectedCategory = nil
                    dismiss()
                } label: {
                    HStack {
                        Text("All Categories")
                        Spacer()
                        if selectedCategory == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                ForEach(categories) { category in
                    Button {
                        selectedCategory = category
                        dismiss()
                    } label: {
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 10, height: 10)
                            Text(category.name)
                            Spacer()
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter by Category")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        ExpenseListView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

