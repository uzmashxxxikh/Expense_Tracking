import CoreData

@objc(Expense)
public class Expense: NSManagedObject, Identifiable {
}

extension Expense {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var merchantName: String
    @NSManaged public var date: Date
    @NSManaged public var category: Category?
}

