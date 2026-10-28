import SwiftUI

/// Achievements-Screen: Übersicht aller Badges (freigeschaltet + gesperrt).
///
/// Bindet an das `AchievementsViewModel` (MVVM). Neue Freischaltungen werden
/// über ein animiertes Overlay gefeiert.
struct AchievementsView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: AchievementsViewModel?
    @Namespace private var badgeNamespace

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Erfolge")
            .figmaScreenBackground()
        }
        .task {
            if viewModel == nil {
                viewModel = AchievementsViewModel(
                    service: dependencies.makeAchievementService(),
                    repository: dependencies.makeRecoveryRepository(),
                    cravingCounter: dependencies.cravingSessionCounter
                )
            }
            await viewModel?.onAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: .activeAddictionDidChange)) { _ in
            Task { await viewModel?.evaluateAndReload() }
        }
        .overlay {
            if let viewModel, !viewModel.newlyUnlocked.isEmpty {
                AchievementUnlockView(
                    achievements: viewModel.newlyUnlocked,
                    namespace: badgeNamespace,
                    onDismiss: viewModel.dismissUnlockAnimation
                )
            }
        }
    }

    private func content(_ viewModel: AchievementsViewModel) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                header(viewModel)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                            .matchedGeometryEffect(id: achievement.id, in: badgeNamespace)
                    }
                }
                .animation(.smooth, value: viewModel.achievements)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
    }

    private func header(_ viewModel: AchievementsViewModel) -> some View {
        let total = max(1, viewModel.achievements.count)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Jeder Schritt verdient Anerkennung.")
                .font(.subheadline)
                .foregroundStyle(AppColor.muted)
            HStack(spacing: 12) {
                IconTile(systemImage: "medal.fill", foreground: AppColor.gold, background: AppColor.goldSoft, size: 46)
                    .symbolEffect(.bounce, value: viewModel.unlockedCount)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.unlockedCount) von \(viewModel.achievements.count) freigeschaltet")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColor.ink)
                        .contentTransition(.numericText(value: Double(viewModel.unlockedCount)))
                    BarProgress(fraction: Double(viewModel.unlockedCount) / Double(total))
                }
            }
            .figmaCard()
        }
    }
}

#Preview {
    AchievementsView()
}
