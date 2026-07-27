import Foundation

/// Abstraktion für den Zugriff auf die Recovery-Daten.
///
/// Die Domain- und Presentation-Schicht kennen ausschließlich dieses
/// Protokoll – niemals SwiftData. Dadurch bleiben ViewModels testbar
/// (Mock-Implementierungen) und die Persistenz austauschbar.
protocol RecoveryRepository: Repository {

    // MARK: - Profil

    /// Lädt das aktuell aktive Profil (Sucht), falls das Onboarding
    /// abgeschlossen wurde.
    func loadProfile() async throws -> RecoveryProfile?

    /// Legt ein neues Profil an (Abschluss des Onboardings). Wird zur aktiven
    /// Sucht, falls noch keine existiert.
    @discardableResult
    func createProfile(_ profile: RecoveryProfile) async throws -> RecoveryProfile

    /// Aktualisiert ein bestehendes Profil.
    func updateProfile(_ profile: RecoveryProfile) async throws

    /// Setzt (oder entfernt mit `nil`) das aktuelle Ziel.
    func updateGoal(_ goal: RecoveryGoal?) async throws

    /// Aktualisiert die gewählte Motivationsquelle.
    func updateMotivationSource(_ source: MotivationSource) async throws

    // MARK: - Süchte (Multi-Addiction)

    /// Liefert alle getrackten Süchte als Zusammenfassung (für Auswahl/Verwaltung).
    func fetchAddictions() async throws -> [AddictionSummary]

    /// Legt eine weitere Sucht an (nicht automatisch aktiv, außer es ist die erste).
    @discardableResult
    func addAddiction(_ profile: RecoveryProfile) async throws -> RecoveryProfile

    /// Wechselt die aktive Sucht auf die angegebene ID.
    func switchAddiction(to id: UUID) async throws

    /// Löscht eine Sucht samt aller zugehörigen Daten. War sie aktiv, wird
    /// automatisch eine andere aktiv gesetzt (falls vorhanden).
    func deleteAddiction(id: UUID) async throws

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

    // MARK: - Recovery-Plan

    /// Lädt den Plan für den angegebenen Tag inkl. Abhak-Zustand.
    func fetchPlan(for day: Date) async throws -> RecoveryPlan
    /// Schaltet den Abhak-Zustand einer Aufgabe an einem Tag um.
    func setTaskCompletion(_ taskId: String, on day: Date, isCompleted: Bool) async throws

    /// Lädt die anpassbare Plan-Definition (Aufgabenliste, sortiert).
    func fetchPlanTasks() async throws -> [PlanTask]
    /// Fügt eine Aufgabe zur Plan-Definition hinzu (ans Ende).
    func addPlanTask(_ task: PlanTask) async throws
    /// Entfernt eine Aufgabe aus der Plan-Definition.
    func removePlanTask(id: String) async throws

    // MARK: - Datenverwaltung

    /// Erstellt einen vollständigen, exportierbaren Snapshot aller Daten.
    func exportData() async throws -> ExportData
    /// Löscht sämtliche persistierten Daten (Profil, Journal, Trigger,
    /// Rückfälle, Achievements) unwiderruflich.
    func deleteAllData() async throws
}