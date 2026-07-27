import Foundation

/// Zentraler, rechtlich relevanter Hinweistext.
///
/// An einer Stelle gepflegt, damit Disclaimer-Screen und Hilfe-Screen
/// denselben Wortlaut verwenden.
enum DisclaimerText {
    /// Kurzform für den Hilfe-Screen und wiederkehrende Hinweise.
    static let short = "Diese App ersetzt keine medizinische oder therapeutische Behandlung. Bei akuten Krisen wende dich bitte an professionelle Hilfe."

    /// Ausführlichere Fassung für den erstmaligen Bestätigungs-Screen.
    static let long = """
    Recovery unterstützt dich auf deinem Weg mit Motivation, Struktur und \
    Selbsthilfe-Werkzeugen. Die App ist jedoch kein Medizinprodukt und stellt \
    keine Diagnose, Behandlung oder Therapie dar.

    Diese App ersetzt keine medizinische oder therapeutische Behandlung. \
    Bei akuten Krisen wende dich bitte an professionelle Hilfe.
    """
}
