import CoreData
import SwiftUI

@objc(Category)
public class Category: NSManagedObject, Identifiable {
}

extension Category {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var iconName: String
    @NSManaged public var colorHex: String
    @NSManaged public var expenses: NSSet?
}

// MARK: - Convenience

extension Category {
    var color: Color {
        Color(hex: colorHex) ?? Color(hex: "#007AFF")!
    }
}

