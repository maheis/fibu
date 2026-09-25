# Implementierungsplan: Fibu Flutter App

## Ausgangslage

Das vorhandene PHP-Projekt in `.notes/fibu` zeigt bereits die fachliche Logik für eine kleine Finanzbuchhaltungs-App:

- Konten mit Guthaben
- Budgets mit Saldo
- Buchungen mit Datum, Betrag, Konto, Wo/Was, Budget
- Monats-/Jahresfilter
- wiederkehrende Buchungen
- Überweisungen

Die Flutter-App soll genau dieses Modell als native Android-App mit Material-3-UI und lokaler Persistenz umsetzen.

## Ziel

Eine fokussierte, leistungsstarke Android-App, die das PHP-Denken in eine digitale, mobile und schnelle Benutzeroberfläche übersetzt.

## Architekturprinzip

Die App folgt dem Muster der bestehenden Flutter-Apps:

- AppController verwaltet den State
- Repository liest/schreibt lokal
- UI zeigt nur den aktuellen App-Status an
- keine direkte Speicherlogik in den Seiten
- Material 3 undAndroid-first UX

## Datenmodell

### Account
- id
- name
- credit
- onlineBanking
- isSubAccount
- createdAt

### Budget
- id
- name
- credit

### Booking
- id
- accountId
- date
- whereId
- whatId
- comment
- amount
- budgetId
- budgetAmount

### Kategorien
- `BookingWhere`: Ort/Verwendungsstelle
- `BookingWhat`: Kategorie/Typ

## Persistenz

- Sembast als lokale Datenbank
- Stores: accounts, budgets, bookings, where, what, settings
- lokale Speicherung im App-Dokumentenordner
- später optionaler Export/Import oder Sync

## UI-Flow

1. Overview
   - Gesamtsaldo
   - Kontenliste
   - Budget-Übersicht
   - Schnellaktionen

2. Buchungen
   - Monatsansicht
   - Filter
   - Suche nach Konto, Kommentar, Kategorie, Betrag
   - Bearbeiten/Löschen

3. Budgets
   - Budgetübersicht
   - aktueller Zustand
   - Verknüpfung zu Buchungen

4. Charts (später)
   - monatliche Einnahmen/Ausgaben
   - Kategorien
   - Kontoverlauf

## MVP-Phasen

### Phase 1 – Projekt-Setup
- Flutter-Projekt initialisieren
- Android-Ziel konfigurieren
- Abhängigkeiten ergänzen
- App-Theme und Grundstruktur

### Phase 2 – Datenbank & Modelle
- Account-, Budget-, Booking-Modelle
- Repository-API
- Seed-Daten für erste Demo

### Phase 3 – Controller & Overview
- AppController
- Gesamt-Saldo
- Konto-Übersicht
- Budget-Übersicht

### Phase 4 – Buchungen
- Monatsliste
- Filtern/Suchen
- neue Buchung anlegen
- Buchung bearbeiten/löschen

### Phase 5 – UX-Polish
- Material 3 Widgets
- FAB für schnelle Eingabe
- Dialoge und BottomSheets
- kompakte Zeilenformate

### Phase 6 – Erweiterungen
- wiederkehrende Buchungen
- Überweisungen
- Charts
- Export/Import

## Technische Umsetzung

### App-Ordnerstruktur

- lib/main.dart
- lib/app.dart
- lib/app_controller.dart
- lib/models.dart
- lib/repository/app_repository.dart
- lib/pages/overview_page.dart
- lib/pages/bookings_page.dart
- lib/pages/budgets_page.dart

## Umsetzungsergebnis

Die erste reale Implementierung wird als funktionierender MVP gestartet, damit die App sofort nutzbar ist und direkt mit echten Daten lokal arbeitet.

## Nächster Schritt

Die Grundlagen werden jetzt direkt im Projekt umgesetzt:

- Datenmodelle
- Repository
- Controller
- erste Seiten
- lokale Demo-Daten
