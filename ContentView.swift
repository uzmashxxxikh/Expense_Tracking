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