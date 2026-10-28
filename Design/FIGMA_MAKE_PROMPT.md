# Figma Make Prompt – „Recovery“ iOS App

> Diesen gesamten Text in Figma Make einfügen.

---

## Rolle & Ziel

Du bist ein erfahrener iOS-Product-Designer. Entwirf ein vollständiges, hochwertiges, modernes UI-Design für die iPhone-App **„Recovery“** – eine App, die Menschen hilft, sich von Süchten und schlechten Gewohnheiten zu befreien.

Das Design soll sich **ruhig, warm, ermutigend und vertrauenswürdig** anfühlen – niemals klinisch, wertend oder beschämend. Die Nutzer befinden sich oft in verletzlichen Momenten (Verlangen, Rückfall). Das Design muss Halt geben, motivieren und Fortschritte feiern.

**Sprache der UI: Deutsch.**

---

## Plattform & technische Rahmenbedingungen

- iPhone, iOS 26, Frame **393 × 852 pt** (iPhone 17)
- Native iOS-Ästhetik (SwiftUI): Apple Human Interface Guidelines, SF Pro, SF Symbols, Liquid-Glass-/Material-Effekte dezent einsetzen
- **Light Mode und Dark Mode** für jeden Haupt-Screen
- Dynamic Type berücksichtigen (keine fixen Mini-Schriften), Mindest-Tap-Fläche 44 pt
- Barrierefrei: WCAG-AA-Kontraste, Informationen nie nur über Farbe
- Tab-Bar-Navigation unten, Sheets für Detail-/Bearbeitungsflows

---

## Visuelle Richtung

- **Stimmung:** Hoffnung, Neuanfang, Ruhe, Stärke. Inspiration: Calm, Headspace, Apple Fitness, „Quittr“.
- **Farben (Vorschlag, gern verfeinern):**
  - Primär/Akzent: beruhigendes Teal/Petrol oder tiefes Grün-Blau
  - Erfolg: frisches Grün (Streaks, Meilensteine)
  - Warnung/Rückfall: warmes, weiches Koralle/Orange – **kein aggressives Rot**
  - Premium: dezentes Gold-Akzent
  - Hintergründe: sanfte Verläufe vom Akzent ins System-Background
- **Typografie:** SF Pro Rounded für große Zahlen (Streak-Zähler), SF Pro für Text. Klare Hierarchie: Large Title → Headline → Body → Caption.
- **Formen:** Karten mit großem Eckradius (20–24 pt), weiche Schatten oder Materialien, viel Weißraum.
- **Spacing-System:** xs 4 / s 8 / m 16 / l 24 / xl 32.
- **Ikonografie:** SF Symbols, gefüllt für aktive Zustände.
- **Motion-Hinweise:** sanfte Feder-Animationen, Atem-Kreis pulsiert, Konfetti/Glow bei Erfolgen.

---

## Unterstützte Süchte / Gewohnheiten

Jede mit eigenem Icon (SF Symbol) und optional eigener Akzent-Nuance:
1. Rauchen
2. Pornografie
3. Alkohol
4. Glücksspiel
5. Zucker
6. Social Media

Nutzer können **mehrere Süchte** tracken (Premium) und zwischen ihnen wechseln.

---

## Navigation (Tab-Bar)

1. **Heute** (Dashboard)
2. **Statistik**
3. **Tagebuch**
4. **Erfolge**
5. **Einstellungen**

Zusätzlich global erreichbar: großer **„Verlangen-Hilfe“-Button** (SOS) und **„Hilfe“**-Bereich.

---

## Screens, die designt werden sollen

### 1. Onboarding (5 Schritte, mit Fortschrittsbalken oben)
1. **Willkommen** – Illustration, Claim, „Los geht’s“-Button
2. **Gewohnheit wählen** – Liste/Grid der 6 Süchte als auswählbare Zeilen mit Icon
3. **Häufigkeit** – wie oft tritt die Gewohnheit auf (auswählbare Optionen)
4. **Dein Grund** – Freitext/Chips: „Warum willst du aufhören?“ (wird später zur Motivation angezeigt)
5. **Zusammenfassung** – Übersicht der Auswahl + „Starten“
- Zusätzlich: **Disclaimer-Screen** (kein Ersatz für medizinische Hilfe), muss bestätigt werden

### 2. Dashboard „Heute“ (wichtigster Screen)
Scrollbare Karten-Ansicht:
- **Header:** Begrüßung + **Sucht-Wechsler** (Dropdown-Menü mit allen Süchten, aktive markiert)
- **Streak-Karte (Hero):** riesige Zahl „12 Tage clean“, Startdatum, Live-Zähler (Tage/Std/Min), Rekord-Streak
- **Fortschritts-Karte:** Ring/Balken zum nächsten Meilenstein (3, 7, 14, 30, 90, 180, 365 Tage)
- **Ziel-Karte:** persönliches Ziel (z. B. 30 Tage) mit Fortschritt, Ziel änderbar (Picker-Sheet)
- **Tagesziel-Karte:** kleines heutiges Ziel abhaken
- **Motivations-Karte:** täglicher Spruch (Zitat / Wissenschaft / Bibelvers), Teilen-Button
- **Recovery-Gains (Premium):** Karten wie „Gespartes Geld: 84 €“, „Zeit zurückgewonnen: 6 Std“, „Gesundheit: Lungenfunktion verbessert“ – mit Kennzahlen-Editor (Kosten/Tag, Zeit/Tag)
- **Recovery-Plan-Karte:** persönlicher Plan / Strategien (bearbeitbar)
- **Großer „Ich habe Verlangen“-Button** (primär, beruhigend, auffällig)
- **Dezenter „Rückfall melden“-Button** (sekundär, nicht beschämend)

### 3. Verlangen-Modus (Craving Mode) – Vollbild, immersiv
Geführter Schritt-für-Schritt-Flow mit Fortschritt:
1. **Willkommen** – „Du schaffst das. Lass uns das gemeinsam durchstehen.“
2. **Atemübung** – animierter, pulsierender Kreis (Einatmen 4s / Halten / Ausatmen), Countdown
3. **Motivation** – personalisierte Botschaft
4. **Affirmation** – großer, ruhiger Satz
5. **Dein Grund** – der beim Onboarding angegebene persönliche Grund
6. **Aufgabe** – kleine Ablenkungsaufgabe (z. B. „Trink ein Glas Wasser“, „10 Liegestütze“)
7. **Abschluss** – Erfolg feiern („Verlangen überstanden!“), zählt für Erfolge
- Dunkler, ruhiger Hintergrund, große Typo, minimale UI, „Schließen“ oben

### 4. Rückfall-Flow (Sheet)
- Einfühlsamer Ton: „Ein Rückfall ist kein Scheitern.“
- Auslöser/Trigger wählen (Chips: Stress, Langeweile, Einsamkeit, Müdigkeit, Social Situation …)
- Stimmung wählen (**Mood Picker** mit 5 Emoji/Gesichtern)
- Optionale Notiz
- Bestätigung → Streak wird zurückgesetzt, aufmunternde Nachricht

### 5. Statistik
- Kennzahlen-Karten (StatCards): aktuelle Streak, längste Streak, Anzahl Rückfälle, überstandene Verlangen
- **Streak-Verlauf-Chart** (Balken/Linie)
- **Rückfall-Historie-Chart**
- **Top-Trigger-Chart** (horizontale Balken)
- Leerzustände (Empty States) für neue Nutzer
- Einige Charts Premium-gesperrt (verblurrt + Schloss)

### 6. Tagebuch (Journal)
- Liste der Einträge (Datum, Stimmungs-Icon, Textvorschau)
- **Editor:** Stimmung wählen, Freitext, Speichern
- Leerzustand mit Einladung zum ersten Eintrag

### 7. Erfolge (Achievements)
- Grid von **Abzeichen/Badges** (Meilensteine, überstandene Verlangen, Tagebuch-Streaks …)
- Freigeschaltet: farbig, leuchtend; gesperrt: grau mit Fortschritt
- **Unlock-Celebration-Overlay:** großes Badge, Glow/Konfetti, „Neuer Erfolg freigeschaltet!“

### 8. Süchte verwalten
- Liste aller getrackten Süchte mit Icon, aktueller Streak, „Aktiv“-Kennzeichnung
- Sucht hinzufügen (Sheet mit Auswahl), löschen (mit Bestätigungsdialog), aktiv setzen
- Für Free-Nutzer: 2. Sucht → Premium-Hinweis

### 9. Inspiration / Motivationsquelle wählen
- Auswahl der Quelle: **Motivationszitate** (gratis), **Wissenschaft**, **Bibelverse**, **Gemischt** (Premium, mit Schloss-Badge)

### 10. Erinnerungen (Notifications)
- Toggles + Uhrzeit-Picker für tägliche Motivation / Check-in

### 11. Hilfe
- Notfall-/Hilfe-Ressourcen als Karten (Hotlines, Beratungsstellen, Links)
- Hinweis-/Disclaimer-Text

### 12. Einstellungen
- Bereiche: Profil/Süchte, Motivationsquelle, Erinnerungen, **Abo** (Status, „Käufe wiederherstellen“, Abo verwalten), App-Icon wählen (Premium), Datenschutz, Hilfe, Rechtliches, Version
- Klassischer iOS-Inset-Grouped-Listenstil

### 13. Paywall (Premium)
- Hero-Bereich mit Illustration/Icon, Titel „Recovery Premium“
- Vorteils-Liste mit Icons:
  - Mehrere Süchte tracken
  - Alle Statistiken
  - Recovery-Gains (Geld, Zeit, Gesundheit)
  - Alle App-Icons
  - Erweiterte Inspiration (Wissenschaft, Bibel, Gemischt)
  - iCloud-Sync
  - Home-Screen-Widgets
- Produktauswahl (z. B. Monatlich / Jährlich mit „Spare X %“-Badge / Lifetime) als auswählbare Zeilen
- Großer CTA „Premium freischalten“, darunter „Käufe wiederherstellen“, Links zu AGB/Datenschutz
- **Locked-Feature-Card:** wiederverwendbare Karte für gesperrte Bereiche (verblurrte Vorschau + Schloss + „Freischalten“)

### 14. Home-Screen-Widgets (Small & Medium)
- **Streak-Widget:** Sucht-Icon + Name, große Tageszahl „Tage clean“, Rekord, kurzer Spruch (Medium: zweispaltig Streak | Spruch). Konfigurierbar: welche Sucht.
- **Motivations-Widget:** nur der Tagesspruch mit Autor. Konfigurierbar: Quelle.
- **Gesperrter Zustand (Free):** verblurrte Vorschau + Schloss + „Premium freischalten“
- Jeweils Light & Dark

---

## Komponenten-Bibliothek (bitte als Figma-Components anlegen)

- PrimaryButton (Default / Pressed / Disabled / Loading)
- SecondaryButton / Destructive-Soft-Button
- SOS-/Verlangen-Button (prominent)
- CardContainer
- StatCard
- SelectableRow (mit Icon, Checkmark-Zustand)
- SelectableChip (Trigger-Auswahl, Multi-Select)
- MoodPicker (5 Stufen)
- AppTextEditor (Tagebuch/Notiz)
- ProgressRing & ProgressBar
- AchievementBadge (locked / unlocked)
- LockedFeatureCard (Premium-Gate)
- ProductOptionRow (Paywall)
- OnboardingProgressBar
- Sucht-Wechsler (Menü)
- Empty-State-Komponente
- Tab-Bar

---

## Tonalität der Texte (Microcopy)

- Du-Form, warm, kurz, ermutigend
- Fortschritt feiern: „Stark! 7 Tage geschafft.“
- Rückfälle entstigmatisieren: „Jeder Neustart zählt.“
- Niemals Schuld, Scham oder Drohungen

---

## Lieferumfang

1. Design-System-Seite (Farben, Typo, Spacing, Komponenten) – Light & Dark
2. Alle oben genannten Screens in Light Mode, die wichtigsten (Dashboard, Verlangen-Modus, Paywall, Widgets) zusätzlich in Dark Mode
3. Klickbarer Prototyp für die Flows: Onboarding → Dashboard → Verlangen-Modus → Abschluss, sowie Dashboard → Rückfall, und Gesperrtes Feature → Paywall
4. Realistische deutsche Beispieldaten (z. B. „Rauchen – 12 Tage clean, Rekord 30 Tage, 84 € gespart“)
