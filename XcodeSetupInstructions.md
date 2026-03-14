# Xcode Setup Instructions for Expense Tracker

## Step 1: Create New Xcode Project
1. Open Xcode
2. File → New → Project
3. Choose "iOS" → "App"
4. Fill in project details:
   - Product Name: `ExpenseTracker`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - **IMPORTANT:** Check "Use Core Data" ✅
   - Choose save location

## Step 2: Project Structure Setup

Your Xcode project should have this structure:
```
ExpenseTracker/
├── ExpenseTracker/
│   ├── ExpenseTrackerApp.swift (replace)
│   ├── ContentView.swift (replace)
│   ├── Persistence.swift (replace)
│   ├── ExpenseTracker.xcdatamodeld/ (Core Data model)
│   ├── Views/
│   │   ├── DashboardView.swift (add)
│   │   ├── ExpenseListView.swift (add)
│   │   ├── AddEditExpenseView.swift (add)
│   │   ├── AnalyticsView.swift (add)
│   │   ├── CategoryManagementView.swift (add)
│   │   └── CategoryDetailView.swift (add)
│   ├── Components/
│   │   ├── TotalSpentCard.swift (add)
│   │   ├── DonutChartView.swift (add)
│   │   ├── RecentActivityList.swift (add)
│   │   └── ExpenseRow.swift (add)
│   ├── Models/
│   │   ├── Expense+CoreData.swift (add)
│   │   ├── Category+CoreData.swift (add)
│   │   └── ExpenseViewModel.swift (add)
│   └── Utilities/
│       ├── DataValidation.swift (add)
│       └── Color+Hex.swift (add)
└── ExpenseTrackerTests/
```

## Step 3: File Replacement Guide

### Replace These Default Files:
1. **ExpenseTrackerApp.swift** - Replace with your version
2. **ContentView.swift** - Replace with your version  
3. **Persistence.swift** - Replace with your version

### Add These New Files:
Right-click on ExpenseTracker folder → New File → Swift File

**Views Folder:**
- DashboardView.swift
- ExpenseListView.swift
- AddEditExpenseView.swift
- AnalyticsView.swift
- CategoryManagementView.swift
- CategoryDetailView.swift

**Components Folder:**
- TotalSpentCard.swift
- DonutChartView.swift
- RecentActivityList.swift
- ExpenseRow.swift

**Models Folder:**
- Expense+CoreData.swift
- Category+CoreData.swift
- ExpenseViewModel.swift

**Utilities Folder:**
- DataValidation.swift
- Color+Hex.swift

## Step 4: Core Data Model Setup

1. **Open ExpenseTracker.xcdatamodeld**
2. **Delete default entity if present**
3. **Add Expense Entity:**
   - Entity Name: `Expense`
   - Attributes:
     - `id`: UUID
     - `amount`: Double
     - `merchantName`: String
     - `date`: Date
   - Relationships:
     - `category`: To One → Category

4. **Add Category Entity:**
   - Entity Name: `Category`
   - Attributes:
     - `id`: UUID
     - `name`: String
     - `iconName`: String
     - `colorHex`: String
   - Relationships:
     - `expenses`: To Many → Expense

5. **Set Relationship Inverses:**
   - Expense.category ↔ Category.expenses

## Step 5: Required Dependencies

Add these to your project:
1. **Charts Framework** (iOS 16+):
   - Project Settings → Target → General
   - Frameworks, Libraries, and Embedded Content
   - Click "+" → Add "Charts"

## Step 6: Build and Run

1. **Select target device:** iPhone simulator or physical device
2. **Build:** Cmd+B
3. **Run:** Cmd+R

## Troubleshooting

### Common Issues:

1. **Core Data Errors:**
   - Ensure Core Data model matches entity definitions
   - Check relationship configurations

2. **Missing Charts Framework:**
   - Add Charts framework in project settings
   - Minimum iOS 16.0 deployment target

3. **Build Errors:**
   - Clean build folder: Shift+Cmd+K
   - Rebuild: Cmd+B

4. **Simulator Issues:**
   - Reset simulator: Device → Erase All Content and Settings

### File Organization Tips:

1. **Create Groups (Folders):**
   - Right-click project → New Group
   - Name: Views, Components, Models, Utilities

2. **Move Files to Groups:**
   - Drag files into appropriate groups
   - This is for organization only (doesn't affect build)

3. **Import Statements:**
   - Each file should have proper imports:
     - `import SwiftUI`
     - `import CoreData` (for data files)
     - `import Charts` (for analytics)

## Step 7: Test the App

1. **Launch app in simulator**
2. **Test core functionality:**
   - Add expenses
   - View dashboard
   - Check analytics
   - Manage categories
3. **Verify data persistence** (close/reopen app)

## Final Notes

- **Minimum iOS Version:** 16.0 (for Charts framework)
- **Xcode Version:** 14.0+ recommended
- **Device Compatibility:** iPhone/iPad
- **Core Data:** Required for data persistence

Your expense tracker should now run successfully in Xcode!