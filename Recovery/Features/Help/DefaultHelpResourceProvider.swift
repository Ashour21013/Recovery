import Foundation

/// Standard-Implementierung des `HelpResourceProvider` mit kuratierten,
/// offiziellen Anlaufstellen für DACH sowie den appeigenen Selbsthilfe-Tools.
///
/// Wichtig: Es werden bewusst **keine Telefon-Hotlines / `tel:`-Links**
/// hinterlegt, sondern ausschließlich Weblinks zu offiziellen Beratungs- und
/// Hilfsangeboten. Neue Länder lassen sich einfach in `externalResources()`
/// ergänzen (Open/Closed).
struct DefaultHelpResourceProvider: HelpResourceProvider {

    func inAppResources() -> [HelpResource] {
        [
            HelpResource(
                id: "inapp.craving",
                title: "Soforthilfe bei Verlangen",
                description: "Starte den Craving-Modus und komme in wenigen geführten Schritten durch die Welle.",
                systemImage: "hand.raised.fill",
                category: .inApp
            ),
            HelpResource(
                id: "inapp.breathing",
                title: "Atemübung",
                description: "Eine 60-Sekunden-Atemübung hilft dir, dich zu beruhigen und neu zu fokussieren.",
                systemImage: "wind",
                category: .inApp
            ),
            HelpResource(
                id: "inapp.plan",
                title: "Dein Recovery-Plan",
                description: "Kleine tägliche Aufgaben geben dir Struktur und Halt.",
                systemImage: "checklist",
                category: .inApp
            ),
            HelpResource(
                id: "inapp.motivation",
                title: "Tägliche Motivation",
                description: "Hol dir eine inspirierende Botschaft aus deiner gewählten Quelle.",
                systemImage: "sparkles",
                category: .inApp
            )
        ]
    }

    func externalResources() -> [(region: SupportRegion, resources: [HelpResource])] {
        SupportRegion.allCases.map { region in
            (region: region, resources: resources(for: region))
        }
    }

    // MARK: - Externe Angebote pro Region

    private func resources(for region: SupportRegion) -> [HelpResource] {
        switch region {
        case .germany:
            return [
                HelpResource(
                    id: "de.suchtunddrogen",
                    title: "Sucht & Drogen Hotline – Infoportal",
                    description: "Bundesweite Informationen und Beratungsangebote der Deutschen Hauptstelle für Suchtfragen.",
                    url: URL(string: "https://www.dhs.de"),
                    systemImage: "cross.case.fill",
                    category: .external(.germany)
                ),
                HelpResource(
                    id: "de.telefonseelsorge",
                    title: "TelefonSeelsorge – Online-Beratung",
                    description: "Kostenlose, anonyme Beratung per Chat und Mail bei seelischen Krisen.",
                    url: URL(string: "https://www.telefonseelsorge.de"),
                    systemImage: "bubble.left.and.bubble.right.fill",
                    category: .external(.germany)
                ),
                HelpResource(
                    id: "de.bzga",
                    title: "BZgA – Hilfe bei Abhängigkeit",
                    description: "Unabhängige Informationen und Selbsttests der Bundeszentrale für gesundheitliche Aufklärung.",
                    url: URL(string: "https://www.bzga.de"),
                    systemImage: "info.circle.fill",
                    category: .external(.germany)
                )
            ]
        case .austria:
            return [
                HelpResource(
                    id: "at.suchthilfe",
                    title: "Suchthilfe Österreich",
                    description: "Überblick über regionale Beratungs- und Behandlungsangebote in Österreich.",
                    url: URL(string: "https://www.suchthilfe.at"),
                    systemImage: "cross.case.fill",
                    category: .external(.austria)
                ),
                HelpResource(
                    id: "at.telefonseelsorge",
                    title: "TelefonSeelsorge Österreich",
                    description: "Anonyme Online- und Chat-Beratung in Krisensituationen.",
                    url: URL(string: "https://www.telefonseelsorge.at"),
                    systemImage: "bubble.left.and.bubble.right.fill",
                    category: .external(.austria)
                )
            ]
        case .switzerland:
            return [
                HelpResource(
                    id: "ch.suchtschweiz",
                    title: "Sucht Schweiz",
                    description: "Stiftung mit Informationen, Beratung und Präventionsangeboten rund um Sucht.",
                    url: URL(string: "https://www.suchtschweiz.ch"),
                    systemImage: "cross.case.fill",
                    category: .external(.switzerland)
                ),
                HelpResource(
                    id: "ch.143",
                    title: "Die Dargebotene Hand – Online-Beratung",
                    description: "Anonyme Beratung per Chat und Mail bei Sorgen und Krisen.",
                    url: URL(string: "https://www.143.ch"),
                    systemImage: "bubble.left.and.bubble.right.fill",
                    category: .external(.switzerland)
                )
            ]
        }
    }
}
