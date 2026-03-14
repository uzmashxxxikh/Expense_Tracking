# COMP3097 Expense Tracker - Test Script

## Screen 1: Dashboard View Tests

### Total Spent Card
- [ ] Verify monthly total displays correctly
- [ ] Check currency formatting ($X.XX)
- [ ] Test with zero expenses (shows $0.00)
- [ ] Test with multiple expenses in current month

### Interactive Pie Chart
- [ ] Chart displays when expenses exist
- [ ] Chart shows correct proportions by category
- [ ] Tap chart to cycle through category selections
- [ ] Visual feedback when category selected
- [ ] Chart hidden when no expenses exist

### Recent Activity List
- [ ] Shows last 5 transactions across all time
- [ ] Displays merchant name, category icon, amount
- [ ] Amount shown in red color
- [ ] List updates when new expense added
- [ ] Shows "No recent activity" when empty

### Quick Add Button
- [ ] Button prominently displayed at bottom
- [ ] Tapping opens Add Expense sheet
- [ ] Button has proper styling and shadow
- [ ] Sheet dismisses after adding expense

### Navigation
- [ ] Gear icon opens Category Management
- [ ] Tab navigation works between screens

## Screen 2: Expense List View Tests

### Transaction Display
- [ ] Expenses grouped by date ("Today", "Yesterday", specific dates)
- [ ] Each row shows merchant, category icon, amount in red
- [ ] Proper date formatting for older transactions
- [ ] List updates in real-time when expenses added/edited

### Search Functionality
- [ ] Search bar filters by merchant name
- [ ] Case-insensitive search works
- [ ] Partial matches work
- [ ] Clear search shows all expenses
- [ ] Search updates results in real-time

### Category Filtering
- [ ] Filter button shows category options
- [ ] Selecting category filters expenses
- [ ] Visual indicators show active filters
- [ ] "All Categories" option shows everything
- [ ] Filter persists during session

### Edit/Delete Operations
- [ ] Tap expense opens edit sheet
- [ ] Swipe left reveals delete option
- [ ] Delete removes expense immediately
- [ ] Edit saves changes correctly
- [ ] Confirmation for destructive actions

### Navigation
- [ ] Floating + button opens Add Expense
- [ ] Gear icon opens Category Management

## Screen 3: Add/Edit Expense View Tests

### Amount Input
- [ ] Numeric keypad appears for amount field
- [ ] Dollar sign prefix displays
- [ ] Decimal input works (X.XX format)
- [ ] Validation: Amount must be > 0
- [ ] Validation: Amount must be ≤ $999,999.99
- [ ] Error message for invalid amounts

### Merchant Name Field
- [ ] Text input with auto-capitalization
- [ ] Validation: Field cannot be empty
- [ ] Validation: Max 100 characters
- [ ] Trimming whitespace works
- [ ] Error message for invalid names

### Category Picker
- [ ] Dropdown shows all available categories
- [ ] Categories display with icons and colors
- [ ] Selection updates properly
- [ ] Validation: Category must be selected
- [ ] First category pre-selected for new expenses

### Date Picker
- [ ] Compact date picker style
- [ ] Validation: Cannot select future dates
- [ ] Validation: Cannot select dates >10 years ago
- [ ] Error messages for invalid dates
- [ ] Current date pre-selected for new expenses

### Form Validation
- [ ] Save button validates all fields
- [ ] Error alerts show specific validation messages
- [ ] Form prevents saving invalid data
- [ ] Success saves to Core Data

### Edit Mode
- [ ] Existing expense data pre-populates fields
- [ ] Title changes to "Edit Expense"
- [ ] Update button saves changes
- [ ] Changes reflect immediately in lists

### Navigation
- [ ] Cancel button dismisses without saving
- [ ] Save/Update button saves and dismisses
- [ ] Navigation title updates correctly

## Screen 4: Analytics View Tests

### Total Spending Display
- [ ] Shows all-time total spending
- [ ] Currency formatting correct
- [ ] Updates when expenses added/removed
- [ ] Handles zero expenses gracefully

### Interactive Pie Chart
- [ ] Chart displays category proportions
- [ ] Tap segments to select categories
- [ ] Selected segment highlighted
- [ ] Cycling through categories works
- [ ] Chart updates when data changes

### Category Selection Details
- [ ] Selected category shows name and icon
- [ ] Exact percentage displayed (X.X%)
- [ ] Dollar amount shown for category
- [ ] Selection indicator visible
- [ ] "Tap chart segments" hint when nothing selected

### Category Breakdown List
- [ ] All categories listed with amounts
- [ ] Progress bars show relative spending
- [ ] Tap rows to select categories
- [ ] Selected rows highlighted
- [ ] Percentages calculated correctly
- [ ] Amounts formatted as currency

### Data Accuracy
- [ ] Chart and list data match
- [ ] Percentages add up to 100%
- [ ] Real-time updates when expenses change
- [ ] Handles categories with zero expenses

### Navigation
- [ ] Gear icon opens Category Management
- [ ] Tab navigation works properly

## Screen 5: Category Management View Tests

### Category List Display
- [ ] All categories shown with icons and colors
- [ ] Transaction count displayed for each
- [ ] Categories sorted alphabetically
- [ ] List updates when categories added/removed

### Add New Category
- [ ] "Add New Category" button opens sheet
- [ ] Name field validation (required, max 50 chars)
- [ ] Duplicate name prevention
- [ ] Color picker works properly
- [ ] Icon grid selection (14 SF Symbols)
- [ ] Preview updates in real-time
- [ ] Save creates category successfully

### Edit Categories
- [ ] Tap category opens detail view
- [ ] Can modify name, icon, color
- [ ] Validation applies to edits
- [ ] Changes save properly
- [ ] Navigation back to list works

### Delete Categories
- [ ] Edit mode enables delete
- [ ] Swipe to delete works
- [ ] Associated expenses deleted too
- [ ] Confirmation for destructive actions
- [ ] List updates after deletion

### Category Detail View
- [ ] Shows category information
- [ ] Edit functionality works
- [ ] Transaction count accurate
- [ ] Navigation back works

### Form Validation
- [ ] Empty name shows error
- [ ] Duplicate names prevented
- [ ] Character limit enforced
- [ ] Error messages clear and helpful

### Visual Elements
- [ ] Icon selection grid responsive
- [ ] Color picker full spectrum
- [ ] Preview shows selected icon/color
- [ ] Visual feedback for selections

## Cross-Screen Integration Tests

### Data Persistence
- [ ] Expenses persist between app launches
- [ ] Categories persist between sessions
- [ ] Relationships maintained properly
- [ ] Core Data saves successfully

### Real-time Updates
- [ ] Adding expense updates all screens
- [ ] Editing expense reflects everywhere
- [ ] Deleting expense removes from all views
- [ ] Category changes update throughout app

### Navigation Flow
- [ ] Tab switching preserves state
- [ ] Sheet presentations work properly
- [ ] Navigation stack handles deep linking
- [ ] Back navigation works correctly

### Error Handling
- [ ] Core Data errors handled gracefully
- [ ] Network unavailable scenarios
- [ ] Memory pressure handling
- [ ] Invalid data recovery

### Performance
- [ ] Smooth scrolling in lists
- [ ] Chart rendering performance
- [ ] Search responsiveness
- [ ] App launch time acceptable

## Data Model Tests

### Expense Entity
- [ ] UUID primary key generated
- [ ] Amount stored as Double
- [ ] Merchant name as String
- [ ] Date stored correctly
- [ ] Category relationship works

### Category Entity
- [ ] UUID primary key generated
- [ ] Name stored as String
- [ ] Icon name stored correctly
- [ ] Color hex conversion works
- [ ] One-to-many relationship with expenses

### Relationships
- [ ] Cascade delete works (category → expenses)
- [ ] Orphaned expenses handled
- [ ] Relationship integrity maintained
- [ ] Fetch requests work properly

### Default Data
- [ ] 6 default categories created on first launch
- [ ] Default categories have proper icons/colors
- [ ] Seeding only happens once
- [ ] Default data structure correct

## Validation System Tests

### Amount Validation
- [ ] Empty amount rejected
- [ ] Non-numeric input rejected
- [ ] Negative amounts rejected
- [ ] Zero amounts rejected
- [ ] Amounts over limit rejected
- [ ] Valid amounts accepted

### Merchant Name Validation
- [ ] Empty names rejected
- [ ] Names over 100 chars rejected
- [ ] Whitespace trimmed properly
- [ ] Valid names accepted

### Category Name Validation
- [ ] Empty names rejected
- [ ] Names over 50 chars rejected
- [ ] Duplicate names rejected (case-insensitive)
- [ ] Valid names accepted

### Date Validation
- [ ] Future dates rejected
- [ ] Dates >10 years ago rejected
- [ ] Valid dates accepted
- [ ] Edge cases handled

## UI/UX Tests

### Accessibility
- [ ] VoiceOver navigation works
- [ ] Semantic labels present
- [ ] Color contrast sufficient
- [ ] Touch targets adequate size

### Visual Design
- [ ] Consistent color scheme
- [ ] Proper spacing and alignment
- [ ] Icons display correctly
- [ ] Typography hierarchy clear

### Responsive Design
- [ ] Works on different screen sizes
- [ ] Orientation changes handled
- [ ] Dynamic type support
- [ ] Safe area respected

### User Feedback
- [ ] Loading states shown
- [ ] Success confirmations
- [ ] Error messages helpful
- [ ] Visual feedback for interactions

---

## Test Execution Checklist

- [ ] All Dashboard tests passed
- [ ] All Expense List tests passed  
- [ ] All Add/Edit Expense tests passed
- [ ] All Analytics tests passed
- [ ] All Category Management tests passed
- [ ] All Integration tests passed
- [ ] All Data Model tests passed
- [ ] All Validation tests passed
- [ ] All UI/UX tests passed

**Total Test Cases: 150+**

**Test Status: [ ] PASS [ ] FAIL**

**Notes:**
_Record any issues or observations during testing_