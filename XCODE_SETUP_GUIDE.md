# Quick Xcode Setup Guide

## Step 1: Create New Xcode Project

1. **Open Xcode**
2. **File → New → Project**
3. **Choose "iOS" → "App"**
4. **Project Settings:**
   - Product Name: `ExpenseTracker`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - ✅ **IMPORTANT: Check "Use Core Data"**

## Step 2: Replace Default Files

**Replace these 3 files with the versions in this folder:**
- `ExpenseTrackerApp.swift`
- `ContentView.swift`
- `Persistence.swift`

## Step 3: Add All Swift Files

**Add all the remaining .swift files to your Xcode project:**

**Main Views:**
- `DashboardView.swift`
- `ExpenseListView.swift`
- `AddEditExpenseView.swift`
- `AnalyticsView.swift`
- `CategoryManagementView.swift`
- `CategoryDetailView.swift`

**Components:**
- `TotalSpentCard.swift`
- `DonutChartView.swift`
- `RecentActivityList.swift`
- `ExpenseRow.swift`

**Models:**
- `Expense+CoreData.swift`
- `Category+CoreData.swift`
- `ExpenseViewModel.swift`

**Utilities:**
- `DataValidation.swift`
- `Color+Hex.swift`

## Step 4: Set Up Core Data Model

1. **Open `ExpenseTracker.xcdatamodeld`**
2. **Delete any existing entities**
3. **Add Expense Entity:**
   - Attributes: `id` (UUID), `amount` (Double), `merchantName` (String), `date` (Date)
   - Codegen: Manual/None
4. **Add Category Entity:**
   - Attributes: `id` (UUID), `name` (String), `iconName` (String), `colorHex` (String)
   - Codegen: Manual/None
5. **Add Relationships:**
   - Expense → Category (To One, Optional, Nullify)
   - Category → Expenses (To Many, Optional, Cascade)

## Step 5: Add Charts Framework

1. **Select project in Navigator**
2. **Select target → General tab**
3. **Frameworks, Libraries, and Embedded Content → Click "+"**
4. **Add "Charts" framework**

## Step 6: Build and Run

1. **Clean Build Folder:** `Shift + Cmd + K`
2. **Build:** `Cmd + B`
3. **Run:** `Cmd + R`

## Troubleshooting

- **Charts import error:** Make sure iOS deployment target is 16.0+
- **Core Data errors:** Verify entity names and relationships match exactly
- **Build errors:** Clean build folder and rebuild

Your expense tracker should now run perfectly in Xcode!