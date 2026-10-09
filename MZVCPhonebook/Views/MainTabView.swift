import SwiftUI

public struct MainTabView: View {
    @StateObject private var store = PhonebookStore()
    @State private var selectedTab: Int = 0

    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: VC Directory
            ContactsView()
                .tabItem {
                    Label("VCs", systemImage: "person.text.rectangle.fill")
                }
                .tag(0)

            // Tab 2: Councils Grid
            CouncilsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Councils", systemImage: "building.columns.fill")
                }
                .tag(1)

            // Tab 3: Government & District Offices
            OfficesView()
                .tabItem {
                    Label("Offices", systemImage: "building.2.fill")
                }
                .tag(2)

            // Tab 4: Emergency Contacts
            EmergencyView()
                .tabItem {
                    Label("Emergency", systemImage: "cross.case.fill")
                }
                .tag(3)

            // Tab 5: About & Support
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
                .tag(4)
        }
        .environmentObject(store)
        .tint(Color.accentColor)
    }
}
