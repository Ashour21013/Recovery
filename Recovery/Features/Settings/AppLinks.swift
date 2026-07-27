import Foundation

/// Zentrale, extern konfigurierbare Links & Kontakte der App.
/// Reine Konstanten – frei von UI und Logik.
enum AppLinks {
    /// Datenschutzrichtlinie (im Browser zu öffnen).
    static let privacyPolicy = URL(string: "https://ashour21013.github.io/Recovery/privacy")!

    /// Allgemeine Geschäftsbedingungen (AGB / Terms of Service).
    static let termsOfService = URL(string: "https://ashour21013.github.io/Recovery/terms")!

    /// App-Store-Seite mit direktem Bewertungs-Deeplink.
    /// Platzhalter-ID – bei Veröffentlichung durch die echte App-ID ersetzen.
    static let appStoreReview = URL(string: "https://apps.apple.com/app/id0000000000?action=write-review")!

    /// Support-/Feedback-E-Mail.
    static let feedbackEmail = "feedback@recovery-app.example"

    /// Fertiger `mailto:`-Link inkl. Betreff.
    static var feedbackMailto: URL? {
        let subject = "Feedback zu Recovery \(AppInfo.fullVersion)"
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = feedbackEmail
        components.queryItems = [URLQueryItem(name: "subject", value: subject)]
        return components.url
    }
}
