import SwiftUI

/// Achievements-Screen: Übersicht aller Badges (freigeschaltet + gesperrt).
///
/// Bindet an das `AchievementsViewModel` (MVVM). Neue Freischaltungen werden
/// über ein animiertes Overlay gefeiert.
struct AchievementsView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: AchievementsViewModel?

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
                    }
                }
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
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.unlockedCount) / \(viewModel.achievements.count)")
                        .font(.title2.weight(.bold))
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
