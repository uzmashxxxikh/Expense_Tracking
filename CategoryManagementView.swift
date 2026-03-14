//
//  CategoryManagementView.swift
//  ExpenseTracker
//
//  Updated to match COMP3097 Project Proposal mockup
//

import SwiftUI
import CoreData

struct CategoryManagementView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .easeInOut
    )
    private var categories: FetchedResults<Category>
    @State private var categoryName = ""
    @State private var selectedColor: Color = .gray
    @State private var selectedIcon: String = "tag.fill"
    @State private var nameError: String?
    @State private var showingAddSheet = false
    
    private let availableColors: [Color] = [
        .gray, .red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .pink
    ]
    
    private let availableIcons: [String] = [
        "tag.fill", "fork.knife", "car.fill", "bolt.fill", "gamecontroller.fill",
        "cart.fill", "house.fill", "figure.walk", "bus.fill", "book.fill",
        "cup.and.saucer.fill", "creditcard.fill", "gift.fill", "graduationcap.fill"
    ]
    
    var body: some View {
        List {
            ForEach(categories) { category in
                NavigationLink {
                    CategoryDetailView(category: category)
                } label: {
                    CategoryRowView(
                        category: category,
                        transactionCount: (category.expenses as? Set<Expense>)?.count ?? 0
                    )
                }
            }
            .onDelete(perform: deleteCategories)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingAddSheet = true
                } label: {
                    Text("Add New Category")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCategorySheet(
                categoryName: $categoryName,
                selectedColor: $selectedColor,
                selectedIcon: $selectedIcon,
                nameError: $nameError,
                availableColors: availableColors,
                availableIcons: availableIcons,
                onAdd: addCategory
            )
            .environment(\.managedObjectContext, context)
        }
    }
    
    private func addCategory() {
        nameError = nil
        
        let existingNames = categories.map { $0.name }
        let validation = DataValidation.validateCategoryName(categoryName, existingNames: existingNames)
        
        guard validation.isValid else {
            nameError = validation.error
            return
        }
        
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let category = Category(context: context)
        category.id = UUID()
        category.name = trimmedName
        category.iconName = selectedIcon
        category.colorHex = selectedColor.toHex
        
        do {
            try context.save()
            
            // Reset form
            categoryName = ""
            selectedColor = .gray
            selectedIcon = "tag.fill"
            showingAddSheet = false
        } catch {
            nameError = "Failed to save category. Please try again."
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            
            // Check if category has expenses
            let expenseCount = (category.expenses as? Set<Expense>)?.count ?? 0
            
            if expenseCount > 0 {
                // For now, we'll delete the expenses too
                // In a production app, you might want to show a confirmation dialog
                if let relatedExpenses = category.expenses as? Set<Expense> {
                    for expense in relatedExpenses {
                        context.delete(expense)
                    }
                }
            }
            
            context.delete(category)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
}

// MARK: - Add Category Sheet

struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var categoryName: String
    @Binding var selectedColor: Color
    @Binding var selectedIcon: String
    @Binding var nameError: String?
    let availableColors: [Color]
    let availableIcons: [String]
    let onAdd: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $categoryName)
                        .font(.body)
                    
                    if let error = nameError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Details")
                }
                
                Section {
                    ColorPicker("Color", selection: $selectedColor, supportsOpacity: false)
                } header: {
                    Text("Appearance")
                }
                
                Section {
                    // Icon Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Icon")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 5), spacing: 16) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Circle()
                                    .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.gray.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        Image(systemName: icon)
                                            .font(.title3)
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
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    // Preview
                    HStack(spacing: 16) {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Image(systemName: selectedIcon)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Preview")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(categoryName.isEmpty ? "Category Name" : categoryName)
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("New Category")
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
                    Button("Add") {
                        onAdd()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Category Row View

struct CategoryRowView: View {
    let category: Category
    let transactionCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Circle()
                .fill(category.color)
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: category.iconName)
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            
            // Category Name
            Text(category.name)
                .font(.headline)
            
            Spacer()
            
            // Transaction Count
            Text("\(transactionCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        CategoryManagementView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}