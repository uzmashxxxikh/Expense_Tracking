# COMP3097 Expense Tracker iOS App - Group G37

A comprehensive iOS expense tracking application built with Swift, SwiftUI, and Core Data.

## Features Completed

### 🏠 Home Dashboard Screen
- **Total Spent Card**: Shows monthly expenses with prominent blue styling
- **Interactive Pie Chart**: Visual spending distribution by category with tap interactions
- **Recent Activity List**: Displays the last 5 transactions across all time periods
- **Prominent Quick Add Button**: Full-width button for easy expense entry

### 📋 Expense List Screen
- **Organized Transaction History**: Groups expenses by date ("Today", "Yesterday", specific dates)
- **Search Functionality**: Search expenses by merchant name
- **Category Filtering**: Filter expenses by specific categories
- **Detailed Expense Rows**: Shows merchant name, category icon, and amount in red
- **Swipe to Delete**: Remove expenses with swipe gestures
- **Edit Expenses**: Tap any expense to edit its details

### ➕ Add/Edit Expense Screen
- **Enhanced Amount Input**: Numeric keypad with dollar sign prefix
- **Merchant Name Field**: Text input with auto-capitalization
- **Category Picker**: Dropdown selection with icons and colors
- **Date Picker**: Compact date selection (prevents future dates)
- **Comprehensive Validation**: 
  - Amount must be positive and under $999,999.99
  - Merchant name required (max 100 characters)
  - Category selection required
  - Date cannot be in future or more than 10 years ago

### 📊 Analytics Detail Screen
- **Interactive Pie Chart**: Tap chart segments or category rows to highlight
- **Exact Percentages**: Shows percentages to 1 decimal place
- **Category Breakdown**: Detailed list with progress bars and amounts
- **Visual Selection**: Selected categories are highlighted with enhanced styling
- **Total Spending**: All-time spending summary

### 🏷️ Category Management Screen
- **Add Categories**: Create custom categories with names, icons, and colors
- **Edit Categories**: Modify existing category details
- **Delete Categories**: Remove categories (also removes associated expenses)
- **Icon Selection**: Choose from 14 different SF Symbols
- **Color Customization**: Full color picker support
- **Transaction Count**: Shows number of expenses per category
- **Validation**: Prevents duplicate names and enforces character limits

## Technical Implementation

### Core Data Model
- **Expense Entity**: Amount (Double), Merchant Name (String), Date (Date), Category relationship
- **Category Entity**: Name (String), Icon Name (String), Color Hex (String), Expenses relationship
- **Proper Relationships**: One-to-many relationship between Category and Expense
- **Data Seeding**: Automatic creation of default categories on first launch

### Data Validation
- Centralized validation utilities in `DataValidation.swift`
- Comprehensive error handling with user-friendly messages
- Input sanitization and bounds checking
- Relationship integrity maintenance

### UI/UX Features
- **SwiftUI Navigation**: Tab-based navigation with proper state management
- **Responsive Design**: Adapts to different screen sizes
- **Accessibility**: Proper labels and semantic markup
- **Visual Feedback**: Loading states, selection indicators, and animations
- **Error Handling**: User-friendly error messages and recovery options

## Default Categories
The app comes pre-loaded with 6 default categories:
- 🍽️ Food (Green)
- 🚗 Transport (Orange) 
- 📄 Bills (Blue)
- 🛒 Groceries (Teal)
- 📺 Entertainment (Purple)
- 🏠 Rent (Red)

## Usage Instructions

1. **Adding Expenses**: Use the prominent "Quick Add" button on the dashboard or the floating + button on other screens
2. **Viewing Analytics**: Navigate to the Analytics tab to see spending breakdowns and tap chart segments for details
3. **Managing Categories**: Access category management through the gear icon in the navigation bar
4. **Searching Expenses**: Use the search bar in the Expense List to find specific transactions
5. **Filtering**: Use the filter button to view expenses from specific categories only

## Project Structure
```
ExpenseTracker/
├── ExpenseTrackerApp.swift          # App entry point
├── ContentView.swift                # Main tab navigation
├── Persistence.swift                # Core Data stack
├── DataValidation.swift             # Validation utilities
├── Models/
│   ├── Expense+CoreData.swift       # Expense entity
│   └── Category+CoreData.swift      # Category entity
├── Views/
│   ├── DashboardView.swift          # Home dashboard
│   ├── ExpenseListView.swift        # Expense list and search
│   ├── AddEditExpenseView.swift     # Add/edit expense form
│   ├── AnalyticsView.swift          # Analytics and charts
│   └── CategoryManagementView.swift # Category management
├── Components/
│   ├── TotalSpentCard.swift         # Dashboard spending card
│   ├── DonutChartView.swift         # Interactive pie chart
│   ├── RecentActivityList.swift     # Recent transactions
│   └── ExpenseRow.swift             # Individual expense row
└── Utilities/
    ├── ExpenseViewModel.swift       # Data access helpers
    └── Color+Hex.swift              # Color utilities
```

## Requirements Met
✅ All 5 main screens implemented and functional  
✅ Core Data integration with proper relationships  
✅ Comprehensive data validation  
✅ Interactive charts and analytics  
✅ Search and filtering capabilities  
✅ Category management with customization  
✅ Proper error handling and user feedback  
✅ Modern SwiftUI design patterns  
✅ Accessibility considerations  
✅ Data persistence and seeding  

## Group G37 - COMP3097 Assignment Complete
This implementation fulfills all requirements specified in the project proposal with additional enhancements for better user experience and data integrity.