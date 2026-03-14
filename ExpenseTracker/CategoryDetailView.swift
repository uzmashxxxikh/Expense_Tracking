//
//  CategoryDetailView.swift
//  ExpenseTracker
//
//  Detail view for editing individual categories
//

import SwiftUI
import CoreData

struct CategoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var category: Category
    
    @State private var categoryName: String = ""
    @State private var selectedColor: Color = .gray
    @State private var selectedIcon: String = "tag.fill"
    @State private var nameError: String?
    @State private var showingDeleteAlert = false
    
    private let availableColors: [Color] = [
        .gray, .red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .pink
    ]
    
    private let availableIcons: [String] = [
        "tag.fill", "fork.knife", "car.fill", "bolt.fill", "gamecontroller.fill",
        "cart.fill", "house.fill", "figure.walk", "bus.fill", "book.fill",
        "cup.and.saucer.fill", "creditcard.fill", "gift.fill", "graduationcap.fill"
    ]
    
    private var expenseCount: Int {
        (category.expenses as? Set<Expense>)?.count ?? 0
    }
    
    var body: some View {
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
            
            Section {
                HStack {
                    Text("Expenses using this category")
                    Spacer()
                    Text("\(expenseCount)")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Usage")
            }
            
            Section {
                Button("Delete Category", role: .destructive) {
                    showingDeleteAlert = true
                }
            }
        }
        .navigationTitle("Edit Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveCategory()
                }
                .fontWeight(.semibold)
            }
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCategory()
            }
        } message: {
            Text("This will delete the category and all \(expenseCount) associated expenses. This action cannot be undone.")
        }
        .onAppear {
            loadCategoryData()
        }
    }
    
    private func loadCategoryData() {
        categoryName = category.name
        selectedColor = category.color
        selectedIcon = category.iconName
    }
    
    private func saveCategory() {
        nameError = nil
        
        // Get all other category names for validation
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let allCategories = (try? context.fetch(request)) ?? []
        let otherNames = allCategories.filter { $0.objectID != category.objectID }.map { $0.name }
        
        let validation = DataValidation.validateCategoryName(categoryName, existingNames: otherNames)
        
        guard validation.isValid else {
            nameError = validation.error
            return
        }
        
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        category.name = trimmedName
        category.iconName = selectedIcon
        category.colorHex = selectedColor.toHex
        
        do {
            try context.save()
            dismiss()
        } catch {
            nameError = "Failed to save category. Please try again."
        }
    }
    
    private func deleteCategory() {
        // Delete all associated expenses
        if let expenses = category.expenses as? Set<Expense> {
            for expense in expenses {
                context.delete(expense)
            }
        }
        
        // Delete the category
        context.delete(category)
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let category = Category(context: context)
    category.id = UUID()
    category.name = "Sample Category"
    category.iconName = "tag.fill"
    category.colorHex = "#007AFF"
    
    return NavigationStack {
        CategoryDetailView(category: category)
            .environment(\.managedObjectContext, context)
    }
}