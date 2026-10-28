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
                title: String(localized: "Soforthilfe bei Verlangen"),
                description: String(localized: "Starte den Craving-Modus und komme in wenigen geführten Schritten durch die Welle."),
                systemImage: "hand.raised.fill",
                category: .inApp
            ),
            HelpResource(
                id: "inapp.breathing",
                title: String(localized: "Atemübung"),
                description: String(localized: "Eine 60-Sekunden-Atemübung hilft dir, dich zu beruhigen und neu zu fokussieren."),
                systemImage: "wind",
                category: .inApp
            ),
            HelpResource(
                id: "inapp.plan",
                title: String(localized: "Dein Recovery-Plan"),
                description: String(localized: "Kleine tägliche Aufgaben geben dir Struktur und Halt."),
                systemImage: "checklist",
                category: .inApp
            ),
            HelpResource(
                id: "inapp.motivation",
                title: String(localized: "Tägliche Motivation"),
                description: String(localized: "Hol dir eine inspirierende Botschaft aus deiner gewählten Quelle."),
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
                    title: String(localized: "Sucht & Drogen Hotline – Infoportal"),
                    description: String(localized: "Bundesweite Informationen und Beratungsangebote der Deutschen Hauptstelle für Suchtfragen."),
                    url: URL(string: "https://www.dhs.de"),
                    systemImage: "cross.case.fill",
                    category: .external(.germany)
                ),
                HelpResource(
                    id: "de.telefonseelsorge",
                    title: String(localized: "TelefonSeelsorge – Online-Beratung"),
                    description: String(localized: "Kostenlose, anonyme Beratung per Chat und Mail bei seelischen Krisen."),
                    url: URL(string: "https://www.telefonseelsorge.de"),
                    systemImage: "bubble.left.and.bubble.right.fill",
                    category: .external(.germany)
                ),
                HelpResource(
                    id: "de.bzga",
                    title: String(localized: "BZgA – Hilfe bei Abhängigkeit"),
                    description: String(localized: "Unabhängige Informationen und Selbsttests der Bundeszentrale für gesundheitliche Aufklärung."),
                    url: URL(string: "https://www.bzga.de"),
                    systemImage: "info.circle.fill",
                    category: .external(.germany)
                )
            ]
        case .austria:
            return [
                HelpResource(
                    id: "at.suchthilfe",
                    title: String(localized: "Suchthilfe Österreich"),
                    description: String(localized: "Überblick über regionale Beratungs- und Behandlungsangebote in Österreich."),
                    url: URL(string: "https://www.suchthilfe.at"),
                    systemImage: "cross.case.fill",
                    category: .external(.austria)
                ),
                HelpResource(
                    id: "at.telefonseelsorge",
                    title: String(localized: "TelefonSeelsorge Österreich"),
                    description: String(localized: "Anonyme Online- und Chat-Beratung in Krisensituationen."),
                    url: URL(string: "https://www.telefonseelsorge.at"),
                    systemImage: "bubble.left.and.bubble.right.fill",
                    category: .external(.austria)
                )
            ]
        case .switzerland:
            return [
                HelpResource(
                    id: "ch.suchtschweiz",
                    title: String(localized: "Sucht Schweiz"),
                    description: String(localized: "Stiftung mit Informationen, Beratung und Präventionsangeboten rund um Sucht."),
                    url: URL(string: "https://www.suchtschweiz.ch"),
                    systemImage: "cross.case.fill",
                    category: .external(.switzerland)
                ),
                HelpResource(
                    id: "ch.143",
                    title: String(localized: "Die Dargebotene Hand – Online-Beratung"),
                    description: String(localized: "Anonyme Beratung per Chat und Mail bei Sorgen und Krisen."),
                    url: URL(string: "https://www.143.ch"),
                    systemImage: "bubble.left.and.bubble.right.fill",
                    category: .external(.switzerland)
                )
            ]
        }
    }
}
