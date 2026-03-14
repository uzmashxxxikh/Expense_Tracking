# Core Data Model Setup

## STEP 4: Set Up Core Data Model

### 4.1 Open Core Data Model File

1. **In Xcode Navigator, find and click:** `ExpenseTracker.xcdatamodeld`
2. **Delete any existing entities** (if present)

### 4.2 Create Expense Entity

1. **Click the "+" button at the bottom** or **Editor → Add Entity**
2. **Name the entity:** `Expense`
3. **Select the Expense entity**
4. **In Data Model Inspector (right panel), set:**
   - Codegen: `Manual/None`
   - Class: `Expense`

### 4.3 Add Expense Attributes

**With Expense entity selected, click "+" in Attributes section:**

| Attribute Name | Type | Optional | Default |
|----------------|------|----------|---------|
| `id` | UUID | ❌ No | - |
| `amount` | Double | ❌ No | 0 |
| `merchantName` | String | ❌ No | - |
| `date` | Date | ❌ No | - |

### 4.4 Create Category Entity

1. **Add another entity:** `Category`
2. **In Data Model Inspector:**
   - Codegen: `Manual/None`
   - Class: `Category`

### 4.5 Add Category Attributes

**With Category entity selected, add attributes:**

| Attribute Name | Type | Optional | Default |
|----------------|------|----------|---------|
| `id` | UUID | ❌ No | - |
| `name` | String | ❌ No | - |
| `iconName` | String | ❌ No | tag.fill |
| `colorHex` | String | ❌ No | #007AFF |

### 4.6 Create Relationships

#### 4.6.1 Expense → Category Relationship

1. **Select Expense entity**
2. **In Relationships section, click "+"**
3. **Configure:**
   - Name: `category`
   - Destination: `Category`
   - Type: `To One`
   - Optional: ✅ Yes
   - Delete Rule: `Nullify`

#### 4.6.2 Category → Expenses Relationship

1. **Select Category entity**
2. **In Relationships section, click "+"**
3. **Configure:**
   - Name: `expenses`
   - Destination: `Expense`
   - Type: `To Many`
   - Optional: ✅ Yes
   - Delete Rule: `Cascade`
   - Inverse: `category` (should auto-populate)

### 4.7 Verify Relationships

**Check that:**
- Expense.category ↔ Category.expenses are properly linked
- Category delete rule is `Cascade` (deleting category deletes expenses)
- Expense delete rule is `Nullify` (deleting expense doesn't delete category)

## STEP 5: Add Charts Framework

### 5.1 Add Charts Framework

1. **Select your project** in Navigator (top-level "ExpenseTracker")
2. **Select your target** (ExpenseTracker under TARGETS)
3. **Go to "General" tab**
4. **Scroll to "Frameworks, Libraries, and Embedded Content"**
5. **Click the "+" button**
6. **Search for "Charts"**
7. **Select "Charts" and click "Add"**

### 5.2 Verify Charts Import

**Make sure these files can import Charts:**
- AnalyticsView.swift
- DonutChartView.swift

**If you get import errors:**
- Clean Build Folder: `Shift + Cmd + K`
- Rebuild: `Cmd + B`

## STEP 6: Build and Run

### 6.1 Select Target Device

**In Xcode toolbar:**
- Choose iPhone simulator (iPhone 15 Pro recommended)
- Or connect physical device

### 6.2 Build Project

1. **Clean Build Folder:** `Shift + Cmd + K`
2. **Build:** `Cmd + B`
3. **Fix any compilation errors**

### 6.3 Run App

1. **Run:** `Cmd + R`
2. **App should launch with:**
   - 3 tabs: Dashboard, Expenses, Analytics
   - Default categories pre-loaded
   - Empty state messages

## STEP 7: Test Core Functionality

### 7.1 Test Adding Expenses

1. **Tap "Quick Add" button on Dashboard**
2. **Fill in expense details:**
   - Amount: 25.99
   - Merchant: Test Store
   - Category: Food
   - Date: Today
3. **Tap "Add"**
4. **Verify expense appears in:**
   - Dashboard recent activity
   - Expenses list
   - Analytics chart

### 7.2 Test Category Management

1. **Tap gear icon** in navigation bar
2. **Tap "Add New Category"**
3. **Create new category:**
   - Name: Shopping
   - Pick color and icon
4. **Verify category appears in:**
   - Category list
   - Add expense picker

### 7.3 Test Data Persistence

1. **Add several expenses**
2. **Close app completely** (stop in Xcode)
3. **Relaunch app**
4. **Verify all data is still there**

## Troubleshooting Common Issues

### Build Errors

**"Cannot find 'Charts' in scope"**
- Ensure Charts framework is added
- Clean and rebuild project
- Check iOS deployment target is 16.0+

**Core Data errors**
- Verify entity names match exactly: `Expense`, `Category`
- Check relationship configurations
- Ensure Codegen is set to `Manual/None`

**Missing files**
- Ensure all Swift files are added to project target
- Check file membership in File Inspector

### Runtime Issues

**App crashes on launch**
- Check Core Data model configuration
- Verify default category seeding in Persistence.swift

**Charts not displaying**
- Ensure sample data exists
- Check Chart data binding
- Verify iOS 16+ deployment target

**Categories not loading**
- Check Core Data relationships
- Verify seeding logic in PersistenceController

### Performance Issues

**Slow app launch**
- Check Core Data initialization
- Verify fetch request efficiency

**UI lag**
- Ensure @FetchRequest is properly configured
- Check for retain cycles in view models

## Final Verification Checklist

- [ ] App builds without errors
- [ ] All 3 tabs navigate properly
- [ ] Can add new expenses
- [ ] Can edit existing expenses
- [ ] Can delete expenses (swipe)
- [ ] Can add new categories
- [ ] Can edit categories
- [ ] Can delete categories
- [ ] Dashboard shows monthly total
- [ ] Analytics shows pie chart
- [ ] Search works in expense list
- [ ] Category filtering works
- [ ] Data persists between app launches
- [ ] Validation prevents invalid data
- [ ] Error messages display properly

**Your COMP3097 Expense Tracker is now ready for submission!**