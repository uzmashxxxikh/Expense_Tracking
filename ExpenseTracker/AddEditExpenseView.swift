//
//  AddEditExpenseView.swift
//  ExpenseTracker
//
//  View for adding and editing expenses
//  Benjamin Antolin

import SwiftUI
import CoreData

struct AddEditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    let existingExpense: Expense?
    
    @State private var amount = ""
    @State private var merchant = ""
    @State private var selectedCategory: Category?
    @State private var selectedDate = Date()
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingAddCategory = false
    
    private var isEditing: Bool {
        existingExpense != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("$")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    TextField("Merchant or item name", text: $merchant)
                        .textInputAutocapitalization(.words)
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                } header: {
                    Text("Expense Details")
                }
                
                Section {
                    CategoryPickerView(selectedCategory: $selectedCategory)
                    
                    Button {
                        showingAddCategory = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New Category")
                        }
                        .foregroundStyle(.blue)
                    }
                } header: {
                    Text("Category")
                }
            }
            .navigationTitle(isEditing ? "Edit Expense" : "New Expense")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Add") {
                        saveExpense()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingAddCategory) {
                QuickAddCategoryView(onCategoryCreated: { newCategory in
                    selectedCategory = newCategory
                })
                .environment(\.managedObjectContext, context)
            }
            .onAppear {
                if let expense = existingExpense {
                    amount = String(format: "%.2f", expense.amount)
                    merchant = expense.merchantName
                    selectedCategory = expense.category
                    selectedDate = expense.date
                } else {
                    preloadFirstCategory()
                }
            }
        }
    }
    
    private func saveExpense() {
        // Validate amount
        let amountValidation = DataValidation.validateAmount(amount)
        guard amountValidation.isValid, let amountValue = amountValidation.amount else {
            errorMessage = amountValidation.error ?? "Invalid amount"
            showingError = true
            return
        }
        
        // Validate merchant
        let merchantValidation = DataValidation.validateMerchantName(merchant)
        guard merchantValidation.isValid else {
            errorMessage = merchantValidation.error ?? "Invalid merchant name"
            showingError = true
            return
        }
        
        // Validate category
        guard let category = selectedCategory else {
            errorMessage = "Please select a category"
            showingError = true
            return
        }
        
        // Validate date
        let dateValidation = DataValidation.validateExpenseDate(selectedDate)
        guard dateValidation.isValid else {
            errorMessage = dateValidation.error ?? "Invalid date"
            showingError = true
            return
        }
        
        let trimmedMerchant = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existingExpense = existingExpense {
            existingExpense.amount = amountValue
            existingExpense.merchantName = trimmedMerchant
            existingExpense.date = selectedDate
            existingExpense.category = category
        } else {
            let expense = Expense(context: context)
            expense.id = UUID()
            expense.amount = amountValue
            expense.merchantName = trimmedMerchant
            expense.date = selectedDate
            expense.category = category
        }
        
        do {
            try context.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save expense. Please try again."
            showingError = true
        }
    }
    
    private func preloadFirstCategory() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        if let first = try? context.fetch(request).first {
            selectedCategory = first
        }
    }
}

struct CategoryPickerView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .easeInOut
    )
    private var categories: FetchedResults<Category>
    
    @Binding var selectedCategory: Category?
    
    var body: some View {
        if categories.isEmpty {
            Text("No categories available")
                .foregroundStyle(.secondary)
        } else {
            Picker("Category", selection: $selectedCategory) {
                Text("Select Category").tag(nil as Category?)
                ForEach(categories) { category in
                    HStack {
                        Image(systemName: category.iconName)
                            .foregroundStyle(category.color)
                        Text(category.name)
                    }
                    .tag(category as Category?)
                }
            }
        }
    }
}

#Preview {
    AddEditExpenseView(existingExpense: nil)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


// MARK: - Quick Add Category View
struct QuickAddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @State private var categoryName = ""
    @State private var selectedColor: Color = .blue
    @State private var selectedIcon: String = "tag.fill"
    @State private var errorMessage: String?
    
    let onCategoryCreated: (Category) -> Void
    
    private let availableColors: [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .pink]
    private let availableIcons: [String] = ["tag.fill", "fork.knife", "car.fill", "bolt.fill", "gamecontroller.fill", "cart.fill", "house.fill", "figure.walk", "bus.fill", "book.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category Name", text: $categoryName)
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay {
                                    if color == selectedColor {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 3)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Circle()
                                .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Image(systemName: icon)
                                        .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
                                }
                                .overlay {
                                    if icon == selectedIcon {
                                        Circle()
                                            .stroke(selectedColor, lineWidth: 3)
                                    }
                                }
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveCategory()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveCategory() {
        let trimmed = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a category name"
            return
        }
        
        let category = Category(context: context)
        category.id = UUID()
        category.name = trimmed
        category.iconName = selectedIcon
        category.colorHex = selectedColor.toHex
        
        do {
            try context.save()
            onCategoryCreated(category)
            dismiss()
        } catch {
            errorMessage = "Failed to save category"
        }
    }
}
