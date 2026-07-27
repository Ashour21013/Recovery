# Widget-Extension – Einrichtung in Xcode

Der gesamte Code für das Home-Screen-Widget ist bereits im Repository
enthalten. Es fehlen nur die **manuellen Xcode-Schritte**, um das
Widget-Target und die App Group anzulegen (das lässt sich nicht
zuverlässig automatisiert erledigen).

## Überblick über die Dateien

| Datei | Zweck | Ziel-Target |
|-------|-------|-------------|
| `Recovery/Shared/WidgetKit/AppGroup.swift` | App-Group-ID + geteilter `UserDefaults` | **App + Widget** |
| `Recovery/Shared/WidgetKit/WidgetSnapshot.swift` | Geteilte Transportstruktur (Streak, Sucht, Sprüche, Premium) | **App + Widget** |
| `Recovery/Shared/WidgetKit/WidgetSnapshotStore.swift` | Lesen/Schreiben in die App Group | **App + Widget** |
| `Recovery/Features/Widget/WidgetSnapshotPublisher.swift` | Baut Snapshot aus Profil + Premium | App |
| `Recovery/Features/Inspiration/MotivationProvider+Collect.swift` | Sammelt Sprüche aus bestehenden Providern | App |
| `RecoveryWidget/RecoveryWidgetBundle.swift` | `@main`-Einstieg der Extension | Widget |
| `RecoveryWidget/RecoveryWidget.swift` | Widget-Konfiguration (Small/Medium) | Widget |
| `RecoveryWidget/RecoveryTimelineProvider.swift` | Timeline (tägliche Aktualisierung) | Widget |
| `RecoveryWidget/RecoveryWidgetView.swift` | Anzeige-Views (inkl. Locked-Zustand) | Widget |
| `RecoveryWidget/Info.plist` | Extension-Info | Widget |
| `RecoveryWidget/RecoveryWidget.entitlements` | App-Group-Berechtigung Widget | Widget |
| `Recovery/Recovery.entitlements` | App-Group-Berechtigung App | App |

## Schritt 1 – Widget-Extension-Target hinzufügen

1. Xcode → **File → New → Target…**
2. Vorlage **Widget Extension** wählen → *Next*.
3. Product Name: **`RecoveryWidget`**.
   - „Include Configuration App Intent" **deaktivieren** (wir nutzen eine
     `StaticConfiguration`).
   - „Include Live Activity" deaktivieren.
4. *Finish* → bei der Nachfrage „Activate scheme?" **Cancel** (nicht nötig).
5. Xcode legt einen Ordner `RecoveryWidget/` mit Vorlagedateien an.
   **Lösche die automatisch erzeugten Vorlage-Swift-Dateien**
   (z. B. `RecoveryWidget.swift`, Bundle, Provider) und ersetze sie durch
   die bereits im Repo vorhandenen Dateien im Ordner `RecoveryWidget/`:
   - Rechtsklick auf die Target-Gruppe → **Add Files to "Recovery"…**
   - Die vier Swift-Dateien aus `RecoveryWidget/` auswählen und dem
     **RecoveryWidget-Target** (Häkchen bei „Target Membership") zuordnen.
   - `Info.plist` und `RecoveryWidget.entitlements` ebenfalls dem Widget-Target
     zuordnen (bzw. die von Xcode erzeugten durch diese ersetzen).

## Schritt 2 – Geteilte Dateien beiden Targets zuordnen

Die drei Dateien in `Recovery/Shared/WidgetKit/` müssen **auch** vom
Widget-Target kompiliert werden:

1. Wähle im Navigator die drei Dateien
   (`AppGroup.swift`, `WidgetSnapshot.swift`, `WidgetSnapshotStore.swift`).
2. Im **File Inspector** (rechte Seitenleiste) unter **Target Membership**
   zusätzlich zum Häkchen bei `Recovery` auch **`RecoveryWidget`** anhaken.

> Diese Dateien enthalten keine App-/UIKit-Abhängigkeiten und sind bewusst
> reine Foundation-Typen, damit sie in beiden Targets kompilieren.

## Schritt 3 – App Group Capability aktivieren (BEIDE Targets)

Gleiche Group-ID für App- **und** Widget-Target:

**App-Group-ID:** `group.no.Recovery`

Für **`Recovery`** (App-Target):
1. Projekt → Target **Recovery** → **Signing & Capabilities**.
2. **+ Capability** → **App Groups**.
3. Gruppe **`group.no.Recovery`** hinzufügen/aktivieren.
4. Sicherstellen, dass **`Recovery/Recovery.entitlements`** als
   „Code Signing Entitlements" gesetzt ist (Xcode macht das i. d. R.
   automatisch; sonst in den Build Settings unter
   `CODE_SIGN_ENTITLEMENTS` eintragen).

Für **`RecoveryWidget`** (Widget-Target):
1. Target **RecoveryWidget** → **Signing & Capabilities**.
2. **+ Capability** → **App Groups**.
3. Dieselbe Gruppe **`group.no.Recovery`** aktivieren.
4. „Code Signing Entitlements" auf
   **`RecoveryWidget/RecoveryWidget.entitlements`** setzen.

> Falls du eine andere Group-ID verwenden möchtest, passe sie an **drei**
> Stellen an: `AppGroup.identifier`, beide `.entitlements`-Dateien.

## Schritt 4 – Bauen & Testen

1. App-Scheme wählen und **Cmd+R** (App starten). Beim Öffnen des Dashboards
   schreibt die App den Snapshot in die App Group.
2. Home-Bildschirm im Simulator → Widget hinzufügen → **Recovery**.
3. Small und Medium testen.

## Funktionsweise (Kurzfassung)

- **Datenfluss:** App → `WidgetSnapshotPublisher` → `WidgetSnapshotStore`
  (App Group) → `RecoveryTimelineProvider` → Widget-Views. Das Widget liest
  **nur** aus der App Group, enthält keine Business-Logik.
- **Sprüche (keine Doppelpflege):** Der Publisher nutzt die vorhandenen
  `MotivationProvider`-Kataloge der App und legt eine reduzierte Liste in die
  App Group. Free-Nutzer erhalten die Basis-Quelle (`quotes`),
  Premium-Nutzer ihre gewählte (erweiterte) Quelle.
- **Täglicher Spruch:** `WidgetSnapshot.quote(for:)` wählt pro Kalendertag
  deterministisch anhand des Tagesindex – konstant über den Tag, neu zum
  Tageswechsel.
- **Timeline:** aktualisiert sich zum nächsten Mitternachtszeitpunkt
  (`.after(nextMidnight)`), zusätzlich sofort bei jedem App-Schreibvorgang
  (`WidgetCenter.reloadAllTimelines()`).
- **Premium-Gating:** `isPremium` kommt aus der App Group. Free-Nutzer sehen
  den dezenten „Premium freischalten"-Hinweis statt echter Daten.
