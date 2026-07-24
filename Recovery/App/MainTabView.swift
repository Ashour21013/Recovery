import SwiftUI

/// Haupt-Navigation der App nach abgeschlossenem Onboarding.
///
/// Bündelt die Top-Level-Bereiche in einer `TabView`. Jeder Tab besitzt
/// seinen eigenen Screen mit eigenem ViewModel.
struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Übersicht", systemImage: "house.fill")
                }

            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }

            StatisticsView()
                .tabItem {
                    Label("Statistik", systemImage: "chart.bar.fill")
                }

            AchievementsView()
                .tabItem {
                    Label("Erfolge", systemImage: "trophy.fill")
                }

            ReminderSettingsView()
                .tabItem {
                    Label("Erinnerungen", systemImage: "bell.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
