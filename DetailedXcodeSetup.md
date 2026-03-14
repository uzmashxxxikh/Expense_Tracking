# Detailed Xcode Setup Instructions - Expense Tracker

## STEP 1: Create New Xcode Project

1. **Open Xcode**
2. **File → New → Project**
3. **Choose Template:**
   - Select "iOS" tab
   - Choose "App"
   - Click "Next"

4. **Project Configuration:**
   - Product Name: `ExpenseTracker`
   - Team: (Your Apple ID)
   - Organization Identifier: `com.yourname.ExpenseTracker`
   - Bundle Identifier: (auto-filled)
   - Language: `Swift`
   - Interface: `SwiftUI`
   - **✅ IMPORTANT: Check "Use Core Data"**
   - Click "Next"

5. **Choose Location and Create**

## STEP 2: Replace Default Files

### 2.1 Replace ExpenseTrackerApp.swift

**Location:** ExpenseTracker/ExpenseTrackerApp.swift

**Delete the default content and replace with:**

```swift
//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Main app entry point - Converted from Flutter/Dart main.dart
//

import CoreData
import SwiftUI

@main
struct ExpenseTrackerApp: App {
    private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
```

### 2.2 Replace ContentView.swift

**Location:** ExpenseTracker/ContentView.swift

**Delete the default content and replace with:**

```swift
import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
                    .navigationTitle("Overview")
                    .toolbar {
                        CategoryToolbarLink()
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationStack {
                ExpenseListView()
                    .navigationTitle("Expenses")
                    .toolbar {
                        CategoryToolbarLink()
                    }
            }
            .tabItem {
                Label("Expenses", systemImage: "list.bullet")
            }
            .tag(1)
            
            NavigationStack {
                AnalyticsView()
                    .navigationTitle("Analytics")
                    .toolbar {
                        CategoryToolbarLink()
                    }
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.pie.fill")
            }
            .tag(2)
        }
        .tint(Color(hex: "#007AFF") ?? .blue)
    }
}

private struct CategoryToolbarLink: View {
    var body: some View {
        NavigationLink {
            CategoryManagementView()
        } label: {
            Image(systemName: "gearshape")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
```

### 2.3 Replace Persistence.swift

**Location:** ExpenseTracker/Persistence.swift

**Delete the default content and replace with:**

```swift
//
//  Persistence.swift
//  ExpenseTracker
//
//  Core Data stack and preview data
//

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample categories for preview
        let categories = [
            ("Food", "fork.knife", "#34C759"),
            ("Transport", "#FF9500"),
            ("Bills", "bolt.fill", "#007AFF"),
            ("Groceries", "cart.fill", "#30B0C7"),
            ("Entertainment", "tv.fill", "#AF52DE"),
            ("Rent", "house.fill", "#FF3B30")
        ]
        
        var createdCategories: [Category] = []
        
        for (name, icon, color) in categories {
            let category = Category(context: viewContext)
            category.id = UUID()
            category.name = name
            category.iconName = icon
            category.colorHex = color
            createdCategories.append(category)
        }
        
        // Create sample expenses
        let expenses = [
            ("Starbucks", 5.99, createdCategories[0]),
            ("Uber", 12.50, createdCategories[1]),
            ("Electricity Bill", 89.99, createdCategories[2]),
            ("Whole Foods", 45.67, createdCategories[3]),
            ("Netflix", 15.99, createdCategories[4])
        ]
        
        for (merchant, amount, category) in expenses {
            let expense = Expense(context: viewContext)
            expense.id = UUID()
            expense.merchantName = merchant
            expense.amount = amount
            expense.date = Date().addingTimeInterval(-Double.random(in: 0...604800)) // Random date within last week
            expense.category = category
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ExpenseTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Seed default categories if none exist
        seedDefaultCategoriesIfNeeded()
    }
    
    private func seedDefaultCategoriesIfNeeded() {
        let context = container.viewContext
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                // Create default categories
                let defaultCategories = [
                    ("Food", "fork.knife", "#34C759"),
                    ("Transport", "car.fill", "#FF9500"),
                    ("Bills", "bolt.fill", "#007AFF"),
                    ("Groceries", "cart.fill", "#30B0C7"),
                    ("Entertainment", "tv.fill", "#AF52DE"),
                    ("Rent", "house.fill", "#FF3B30")
                ]
                
                for (name, icon, color) in defaultCategories {
                    let category = Category(context: context)
                    category.id = UUID()
                    category.name = name
                    category.iconName = icon
                    category.colorHex = color
                }
                
                try context.save()
            }
        } catch {
            print("Failed to seed default categories: \(error)")
        }
    }
}
```

## STEP 3: Add New Swift Files

### 3.1 Create File Structure

**Right-click on "ExpenseTracker" folder in Xcode → New Group**

Create these groups (folders):
- Views
- Components  
- Models
- Utilities

### 3.2 Add Files to Views Group

**Right-click "Views" group → New File → Swift File**

#### 3.2.1 DashboardView.swift
```swift
//
//  DashboardView.swift
//  ExpenseTracker
//
//  Converted from dashboard_screen.dart
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var showingAddExpense = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .easeInOut
    )
    private var allExpenses: FetchedResults<Expense>
    
    private var currentMonthExpenses: [Expense] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
        return allExpenses.filter { $0.date >= interval.start && $0.date < interval.end }
    }
    
    private var totalThisMonth: Double {
        currentMonthExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var recentFive: [Expense] {
        Array(allExpenses.sorted(by: { $0.date > $1.date }).prefix(5))
    }
    
    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Overview")
                                .font(.title)
                                .fontWeight(.bold)
                            Text(monthYearTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    
                    TotalSpentCard(total: totalThisMonth)
                    
                    DonutChartView(expenses: currentMonthExpenses)
                    
                    RecentActivityList(expenses: recentFive)
                }
                .padding()
            }
            
            Button {
                showingAddExpense = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Quick Add")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#007AFF") ?? .blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .sheet(isPresented: $showingAddExpense) {
                AddEditExpenseView(existingExpense: nil)
                    .environment(\.managedObjectContext, context)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
```

#### 3.2.2 ExpenseListView.swift
```swift
//
//  ExpenseListView.swift
//  ExpenseTracker
//
//  List view for all expenses with search and filtering
//

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
        
        // Filter by search text
        if !searchText.isEmpty {
            expenses = expenses.filter { expense in
                expense.merchantName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
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
                // Search and Filter Bar
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
                
                // Expense List
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
            
            // Floating Add Button
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
```

I'll continue with the remaining files in the next part. This is getting quite long, so let me break it into manageable sections. Would you like me to continue with the remaining Swift files?