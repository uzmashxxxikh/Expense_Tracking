//
//  AddEditExpenseView.swift
//  ExpenseTracker
//
//  View for adding and editing expenses
//

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

