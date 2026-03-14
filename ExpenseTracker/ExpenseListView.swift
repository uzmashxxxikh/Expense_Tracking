//
//  ExpenseListView.swift
//  ExpenseTracker
//
//  List view for all expenses with search and filtering


import SwiftUI
import CoreData

struct ExpenseListView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var showingAddExpense = false
    @State private var editingExpense: Expense?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .easeInOut
    )
    private var allExpenses: FetchedResults<Expense>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .easeInOut
    )
    private var categories: FetchedResults<Category>
    
    private var filteredExpenses: [Expense] {
        var expenses = Array(allExpenses)
        
    
        if !searchText.isEmpty {
            expenses = expenses.filter { expense in
                expense.merchantName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
       
        if let selectedCategory = selectedCategory {
            expenses = expenses.filter { $0.category == selectedCategory }
        }
        
        return expenses
    }
    
    private var groupedExpenses: [(String, [Expense])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            if calendar.isDateInToday(expense.date) {
                return "Today"
            } else if calendar.isDateInYesterday(expense.date) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter.string(from: expense.date)
            }
        }
        
        return grouped.sorted { first, second in
            if first.key == "Today" { return true }
            if second.key == "Today" { return false }
            if first.key == "Yesterday" { return true }
            if second.key == "Yesterday" { return false }
            return first.key > second.key
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search expenses...", text: $searchText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All Categories",
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(categories) { category in
                                FilterChip(
                                    title: category.name,
                                    color: category.color,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
             
                if filteredExpenses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No expenses found")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        if !searchText.isEmpty || selectedCategory != nil {
                            Text("Try adjusting your search or filters")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(groupedExpenses, id: \.0) { section, expenses in
                            Section(section) {
                                ForEach(expenses) { expense in
                                    ExpenseRow(expense: expense)
                                        .onTapGesture {
                                            editingExpense = expense
                                        }
                                }
                                .onDelete { indexSet in
                                    deleteExpenses(from: expenses, at: indexSet)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            
          
            Button {
                showingAddExpense = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(hex: "#007AFF") ?? .blue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showingAddExpense) {
            AddEditExpenseView(existingExpense: nil)
                .environment(\.managedObjectContext, context)
        }
        .sheet(item: $editingExpense) { expense in
            AddEditExpenseView(existingExpense: expense)
                .environment(\.managedObjectContext, context)
        }
    }
    
    private func deleteExpenses(from expenses: [Expense], at offsets: IndexSet) {
        for index in offsets {
            context.delete(expenses[index])
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to delete expense: \(error)")
        }
    }
}

struct FilterChip: View {
    let title: String
    var color: Color = .gray
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    NavigationStack {
        ExpenseListView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
