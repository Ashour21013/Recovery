import Foundation

/// Abstraktion für den Zugriff auf die Recovery-Daten.
///
/// Die Domain- und Presentation-Schicht kennen ausschließlich dieses
/// Protokoll – niemals SwiftData. Dadurch bleiben ViewModels testbar
/// (Mock-Implementierungen) und die Persistenz austauschbar.
protocol RecoveryRepository: Repository {

    // MARK: - Profil

    /// Lädt das aktuelle Profil, falls das Onboarding abgeschlossen wurde.
    func loadProfile() async throws -> RecoveryProfile?

    /// Legt ein neues Profil an (Abschluss des Onboardings).
    @discardableResult
    func createProfile(_ profile: RecoveryProfile) async throws -> RecoveryProfile

    /// Aktualisiert ein bestehendes Profil.
    func updateProfile(_ profile: RecoveryProfile) async throws

    // MARK: - Journal

    func fetchJournalEntries() async throws -> [JournalEntry]
    func addJournalEntry(_ entry: JournalEntry) async throws
    func deleteJournalEntry(id: UUID) async throws

    // MARK: - Trigger

    func fetchTriggers() async throws -> [Trigger]
    func addTrigger(_ trigger: Trigger) async throws
    func deleteTrigger(id: UUID) async throws

    // MARK: - Rückfälle

    func fetchRelapses() async throws -> [Relapse]
    /// Dokumentiert einen Rückfall und setzt die Streak zurück.
    func recordRelapse(_ relapse: Relapse) async throws
}
