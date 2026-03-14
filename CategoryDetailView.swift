import SwiftUI
import CoreData

struct CategoryDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var category: Category
    
    @State private var name: String = ""
    @State private var color: Color = .gray
    @State private var iconName: String = "tag.fill"
    
    private let availableIcons: [String] = [
        "tag.fill", "fork.knife", "car.fill", "doc.text.fill", "cart.fill",
        "tv.fill", "house.fill", "gamecontroller.fill", "creditcard.fill",
        "graduationcap.fill"
    ]
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
            }
            
            Section("Appearance") {
                ColorPicker("Color", selection: $color, supportsOpacity: false)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 5), spacing: 16) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Circle()
                            .fill(iconName == icon ? color.opacity(0.2) : Color.gray.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: icon)
                                    .foregroundStyle(iconName == icon ? color : .secondary)
                            }
                            .overlay {
                                if iconName == icon {
                                    Circle()
                                        .stroke(color, lineWidth: 2)
                                }
                            }
                            .onTapGesture {
                                iconName = icon
                            }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Edit Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            name = category.name
            color = Color(hex: category.colorHex) ?? .gray
            iconName = category.iconName
        }
    }
    
    private func save() {
        category.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        category.colorHex = color.toHex
        category.iconName = iconName
        try? context.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
    }
}

