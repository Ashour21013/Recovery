import SwiftUI

/// Löst die UI-unabhängige `AchievementColor` in eine SwiftUI-`Color` auf.
extension AchievementColor {
    var color: Color {
        switch self {
        case .orange: .orange
        case .green: .green
        case .blue: .blue
        case .red: .red
        case .yellow: .yellow
        case .purple: .purple
        case .teal: .teal
        case .indigo: .indigo
        case .pink: .pink
        case .mint: .mint
        }
    }
}
