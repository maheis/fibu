# Einheitliche UI Controls, Design und Settings

## Status

Umgesetzt in dieser App.

## Gemeinsamer Standard

Alle Apps in `m.git` sollen dieselbe UI-Settings-Auswahl anbieten:

- Schriftart: `OpenDyslexic`, `NotoSans`, `CourierPrime`, `Ubuntu`, `Ubuntu Mono`
- Schriftgröße: 50 % bis 160 %
- Designmodus: hell oder dunkel
- Akzentfarbe: Rot, Orange, Grün, Gelb, Blau, Mint, Lila
- Highlight-Farbe: Rot, Orange, Grün, Gelb, Blau, Mint, Lila

## Fibu Umsetzung

- Settings-Datei: `lib/ui_settings.dart`
- Persistenz: Sembast Store `ui_settings`, Record `app`
- Einstieg: AppBar-Icon `Einstellungen`
- Theme-Anwendung: `buildUnifiedTheme(...)` in `lib/app.dart`
- Textskalierung: `MediaQuery.textScaler`

## Validierung

- `flutter analyze`
- `flutter test test/widget_test.dart --reporter compact`

Beides war nach der Umstellung grün.
