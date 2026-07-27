import Foundation
import Observation

/// ViewModel des Hilfe- & Ressourcen-Screens (MVVM).
///
/// Bereitet die Ressourcen aus dem `HelpResourceProvider` für die View auf.
/// Enthält keine UI- und keine Persistenzlogik.
@Observable
@MainActor
final class HelpViewModel: ViewModel {

    /// Appeigene Selbsthilfe-Ressourcen.
    private(set) var inAppResources: [HelpResource] = []

    /// Externe Angebote, gruppiert nach Region.
    private(set) var externalSections: [ExternalSection] = []

    /// Steuert, ob der Craving-Modus geöffnet werden soll (In-App-Aktion).
    var isShowingCravingMode = false

    /// Rechtlicher Kurz-Hinweis für den Screen.
    let disclaimer = DisclaimerText.short

    private let provider: HelpResourceProvider

    init(provider: HelpResourceProvider) {
        self.provider = provider
    }

    /// Lädt die Ressourcen (einmalig beim Erscheinen).
    func onAppear() {
        guard inAppResources.isEmpty else { return }
        inAppResources = provider.inAppResources()
        externalSections = provider.externalResources()
            .filter { !$0.resources.isEmpty }
            .map { ExternalSection(region: $0.region, resources: $0.resources) }
    }

    /// Reaktion auf Tap einer In-App-Ressource.
    func handleInAppTap(_ resource: HelpResource) {
        if resource.id == "inapp.craving" {
            isShowingCravingMode = true
        }
        // Weitere In-App-Ressourcen sind informativ und lösen keine Navigation aus.
    }

    /// Eine nach Region gruppierte Sektion externer Angebote.
    struct ExternalSection: Identifiable {
        let region: SupportRegion
        let resources: [HelpResource]
        var id: String { region.id }
    }
}
