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
        GridItem(.adaptive(minimum: 96), spacing: AppSpacing.l)
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
            .background(Color(.systemGroupedBackground))
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
            VStack(spacing: AppSpacing.l) {
                header(viewModel)

                LazyVGrid(columns: columns, spacing: AppSpacing.l) {
                    ForEach(viewModel.achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                            .matchedGeometryEffect(id: achievement.id, in: badgeNamespace)
                    }
                }
                .animation(.smooth, value: viewModel.achievements)
            }
            .padding(AppSpacing.l)
        }
    }

    private func header(_ viewModel: AchievementsViewModel) -> some View {
        CardContainer {
            HStack(spacing: AppSpacing.m) {
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
                    .symbolEffect(.bounce, value: viewModel.unlockedCount)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.unlockedCount) / \(viewModel.achievements.count)")
                        .font(.title2.weight(.bold))
                        .contentTransition(.numericText(value: Double(viewModel.unlockedCount)))
                        .animation(.smooth, value: viewModel.unlockedCount)
                    Text("Erfolge freigeschaltet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    AchievementsView()
}
