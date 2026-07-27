import SwiftUI

/// Menü zum schnellen Wechseln der aktiven Sucht (Dashboard-Toolbar).
///
/// Zeigt die aktive Sucht als Titel und listet alle Süchte zum Wechseln.
/// Ganz unten führt „Verwalten…" in die vollständige Verwaltung.
/// Reine UI-Komponente – meldet Aktionen nach außen.
struct AddictionSwitcherMenu: View {
    let addictions: [AddictionSummary]
    let onSwitch: (UUID) -> Void
    let onManage: () -> Void

    private var active: AddictionSummary? {
        addictions.first(where: { $0.isActive }) ?? addictions.first
    }

    var body: some View {
        Menu {
            if addictions.count > 1 {
                Section("Wechseln zu") {
                    ForEach(addictions) { addiction in
                        Button {
                            onSwitch(addiction.id)
                        } label: {
                            Label(
                                "\(addiction.emoji)  \(addiction.title)",
                                systemImage: addiction.isActive ? "checkmark" : ""
                            )
                        }
                    }
                }
            }
            Button {
                onManage()
            } label: {
                Label("Süchte verwalten…", systemImage: "slider.horizontal.3")
            }
        } label: {
            HStack(spacing: AppSpacing.xs) {
                if let active {
                    Text(active.emoji)
                    Text(active.title)
                        .font(AppFont.subheadline.weight(.semibold))
                        .lineLimit(1)
                }
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(.primary)
        }
        .accessibilityLabel("Aktive Sucht: \(active?.title ?? "keine"). Zum Wechseln antippen.")
    }
}

#Preview {
    AddictionSwitcherMenu(
        addictions: [
            AddictionSummary(id: UUID(), habitType: .smoking, currentStreakDays: 12, bestStreakDays: 20, isActive: true),
            AddictionSummary(id: UUID(), habitType: .sugar, currentStreakDays: 3, bestStreakDays: 5, isActive: false)
        ],
        onSwitch: { _ in },
        onManage: {}
    )
}
