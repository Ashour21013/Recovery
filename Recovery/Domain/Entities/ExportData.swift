import Foundation

/// Vollständiger, exportierbarer Snapshot aller Nutzerdaten.
///
/// Reine Domain-Entität, `Codable` für den JSON-Export. Enthält keine
/// Persistenz- oder UI-Details.
struct ExportData: Codable, Equatable {
    let exportedAt: Date
    let appVersion: String
    let profile: ProfileExport?
    let journalEntries: [JournalEntryExport]
    let triggers: [TriggerExport]
    let relapses: [RelapseExport]

    struct ProfileExport: Codable, Equatable {
        let habitType: String
        let reason: String
        let frequency: String?
        let startDate: Date
        let bestStreakDays: Int
        let goalDays: Int?
    }

    struct JournalEntryExport: Codable, Equatable {
        let date: Date
        let text: String
        let mood: Int?
        let triggerName: String?
    }

    struct TriggerExport: Codable, Equatable {
        let name: String
        let note: String
        let createdAt: Date
    }

    struct RelapseExport: Codable, Equatable {
        let date: Date
        let note: String
        let cravingIntensity: Int
        let triggerNames: [String]
    }
}

extension ExportData {
    /// Serialisiert den Snapshot als gut lesbares JSON.
    func makeJSONData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
}
