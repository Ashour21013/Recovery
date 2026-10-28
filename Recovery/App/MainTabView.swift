import SwiftUI

/// Haupt-Navigation (Figma): Heute · Statistik · Tagebuch · Erfolge · Mehr.
struct MainTabView: View {
    var onDataDeleted: () -> Void = {}

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Heute", systemImage: "house") }
            StatisticsView()
                .tabItem { Label("Statistik", systemImage: "chart.bar") }
            JournalView()
                .tabItem { Label("Tagebuch", systemImage: "book") }
            AchievementsView()
                .tabItem { Label("Erfolge", systemImage: "medal") }
            SettingsView(onDataDeleted: onDataDeleted)
                .tabItem { Label("Mehr", systemImage: "gearshape") }
        }
        .tint(AppColor.teal)
        .toolbarBackground(AppColor.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#Preview {
    MainTabView()
}
