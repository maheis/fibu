# Fibu

Fibu ist eine lokale Finanzbuchhaltungs-App fuer Android und Linux. Sie dient zur privaten Verwaltung von Konten, Budgets, Buchungen, Umbuchungen, Dauerbuchungen und Auswertungen.

## Funktionen

- Konten und Kontostand verwalten
- Budgets erfassen und Monatswerte auswerten
- Buchungen lokal speichern
- Umbuchungen zwischen Konten anlegen
- Dauerbuchungen speichern und faellige Buchungen erzeugen
- Jahres- und Monatsauswertung anzeigen
- Lokales JSON-Backup exportieren
- Gemeinsame UI-Settings fuer Schrift, Textgroesse, Akzentfarbe, Highlight-Farbe und hell/dunkel

## Plattformen

- Android
- Linux Desktop

## Technik

- Flutter / Dart
- Sembast fuer lokale Persistenz
- `path_provider` fuer App-Dokumentordner
- `intl` fuer Formatierung

## Entwicklung

```bash
flutter pub get
flutter analyze
flutter test test/widget_test.dart --reporter compact
flutter build linux --debug
```

Android-Builds benoetigen lokal ein vollstaendiges JDK mit `javac`.

## Datenschutz

Fibu speichert Finanzdaten lokal auf dem Geraet. Es gibt derzeit keine Cloud-Synchronisierung und keine automatische Serveruebertragung. Details stehen in `PRIVACY.md`.

## Rechtliches

Der Source Code steht unter MIT-Lizenz. Name, Logo, Icons und sonstige Brand Assets sind separat geschuetzt. Details stehen in `LICENSE`, `TRADEMARK.md` und `THIRD_PARTY_LICENSES.md`.

## footnote

Developed with the kind support of Copilot
