import Foundation
import Observation

/// ViewModel des Craving-Modus (MVVM).
///
/// Steuert den schrittweisen Notfallplan: Navigation zwischen den Schritten,
/// den 60-Sekunden-Atem-Countdown sowie das Laden des persönlichen „Warum".
/// Kennt keine UI- oder Persistenzdetails (nutzt nur das Repository).
@MainActor
@Observable
final class CravingModeViewModel: ViewModel {

    /// Alle Schritte in Reihenfolge (modular über `CravingStep` erweiterbar).
    let steps = CravingStep.allCases

    private(set) var currentIndex = 0

    /// Persönlicher Grund aus dem Profil (Schritt „Dein Warum").
    private(set) var reason: String = ""

    /// Zufällig gewählte Aufgabe für diesen Durchlauf.
    private(set) var task: CravingTask = .random()

    /// Zufällig gewählte Affirmation für diesen Durchlauf.
    private(set) var affirmation: Affirmation = .random()

    // MARK: - Atemübung

    let breathingDuration = 60
    private(set) var remainingSeconds = 60
    private(set) var isBreathingRunning = false
    private var breathingTask: Task<Void, Never>?

    private let repository: RecoveryRepository

    init(repository: RecoveryRepository) {
        self.repository = repository
    }

    // MARK: - Abgeleiteter Zustand

    var currentStep: CravingStep { steps[currentIndex] }
    var isFirstStep: Bool { currentIndex == 0 }
    var isLastStep: Bool { currentIndex == steps.count - 1 }
    var progress: Double { Double(currentIndex + 1) / Double(steps.count) }

    var breathingProgress: Double {
        guard breathingDuration > 0 else { return 1 }
        return Double(breathingDuration - remainingSeconds) / Double(breathingDuration)
    }

    // MARK: - Laden

    func onAppear() async {
        if let profile = try? await repository.loadProfile() {
            reason = profile.reason
        }
    }

    // MARK: - Navigation

    func goNext() {
        guard !isLastStep else { return }
        currentIndex += 1
    }

    func goBack() {
        guard !isFirstStep else { return }
        stopBreathing()
        currentIndex -= 1
    }

    // MARK: - Atemübung-Steuerung

    func startBreathing() {
        guard !isBreathingRunning else { return }
        remainingSeconds = breathingDuration
        isBreathingRunning = true
        breathingTask = Task { [weak self] in
            await self?.runCountdown()
        }
    }

    func stopBreathing() {
        breathingTask?.cancel()
        breathingTask = nil
        isBreathingRunning = false
    }

    private func runCountdown() async {
        while remainingSeconds > 0 && !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            remainingSeconds -= 1
        }
        isBreathingRunning = false
    }
}
