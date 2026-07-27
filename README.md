# BikeDrop 🚲📦
 
Mobile App für Mitarbeiter eines Fahrradladens zur schnellen Erfassung neu
eingetroffener Ware und zum Überblick über den aktuellen Warenbestand.
 
> Eigenständiges Folgeprojekt: eine Angular-Kundenwebsite liest später aus
> derselben Supabase-Datenbank und zeigt Kunden ausgewählte, neu eingetroffene
> Produkte. Details dazu im separaten Repo/Spec.
 
<!-- TODO: kurzes GIF oder 4 Screenshots (Login, Übersicht, Ware erfassen, Detail) hier einfügen -->
 
## Inhalt
 
- [BikeDrop 🚲📦](#bikedrop-)
  - [Inhalt](#inhalt)
  - [Über das Projekt](#über-das-projekt)
  - [Screens](#screens)
  - [Tech-Stack](#tech-stack)
  - [Architektur](#architektur)
  - [Architecture Decisions](#architecture-decisions)
  - [Setup](#setup)
  - [Testing](#testing)
  - [Scope \& Roadmap](#scope--roadmap)
  - [passt zur Größe eines einzelnen Ladens)](#passt-zur-größe-eines-einzelnen-ladens)
## Über das Projekt
 
Mitarbeiter sollen neu eingetroffene Ware schnell über eine Flutter-App
erfassen und den aktuellen Warenbestand überblicken können — ohne Papierliste,
ohne Excel, ohne Umweg über den Laptop im Lager.
 
**v1-Umfang:** ein Standort, individuelle Mitarbeiter-Logins, durchgehende
Internetverbindung vorausgesetzt (kein Offline-Modus). Bewusst schlank
gehalten, um schnell echtes Nutzungsfeedback zu bekommen — siehe
[Scope & Roadmap](#scope--roadmap).
 
## Screens
 
| Login | Übersicht | Ware erfassen | Artikel-Detail |
|---|---|---|---|
| <!-- Screenshot --> | <!-- Screenshot --> | <!-- Screenshot --> | <!-- Screenshot --> |
 
- **Login** — E-Mail/Passwort über Supabase Auth, kein Self-Signup (v1).
- **Übersicht** — Liste aller Artikel (neueste zuerst), Foto-Thumbnail, Menge,
  Sichtbarkeits-Status für die Kunden-Website, Pull-to-Refresh.
- **Ware erfassen** — Formular mit Pflichtfeldern (Name, Menge, Kategorie als
  Dropdown, Preis, Lieferant) + Pflicht-Foto (Kamera/Galerie).
- **Artikel-Detail** — alle Felder editierbar, Sichtbarkeits-Toggle,
  Löschen mit Bestätigungsdialog.
## Tech-Stack
 
- **Flutter** (Android + iOS)
- **Riverpod** (State Management)
- **Supabase** — Postgres (Datenbank), Auth (E-Mail/Passwort), Storage (Produktfotos)
## Architektur
 
- **Repository-Pattern**: `SupabaseRepository` ist die einzige Stelle, die mit
  Supabase spricht (Login, Artikel anlegen/laden/aktualisieren/löschen,
  Sichtbarkeit umschalten, Foto-Upload).
- Riverpod-Provider stellen Auth-Status und Artikel-Liste der UI bereit.
- `employees` wird nicht als eigene Tabelle geführt, sondern direkt über
  Supabase Auth (`auth.users`) verwaltet — da nur ein Standort und keine
  Rollen-Unterscheidung nötig ist.
```
lib/
 ├─ repository/     # SupabaseRepository (einzige Schnittstelle zu Supabase)
 ├─ providers/      # Riverpod-Provider (Auth, Item-Liste)
 ├─ screens/        # Login, Übersicht, Ware erfassen, Artikel-Detail
 └─ models/         # Item-Model
```
 
## Architecture Decisions
 
**Warum Repository-Pattern statt Provider oder BLoC?**
Provider wäre für 4 Screens und einen Standort zwar einfacher gewesen, ist aber
weniger zukunftsfähig, sobald Logik oder Testanforderungen wachsen. BLoC wäre
für diesen Umfang zu viel Ceremony. Das Repository-Pattern trifft den
passenden Aufwand: testbar (Repository lässt sich mocken), aktueller
Flutter/Supabase-Standard, und einfach erweiterbar, falls später z. B. ein
zweiter Standort oder Offline-Caching dazukommt.
 
**Warum Kategorie als Dropdown statt Freitext?**
Ursprünglich als Freitext geplant, dann umgestellt, um Dateninkonsistenzen zu
vermeiden (`"Ersatzteile"` vs. `"ersatzteil"` vs. `"Teile"`). Eine feste,
verwaltbare Liste an Kategorien sorgt für saubere Filterung und Auswertung.
 
**Warum kein Offline-Modus in v1?**
Durchgehende Internetverbindung ist im Lager/Werkstatt-Alltag eine
realistische Annahme; Offline-Sync hätte den Aufwand für v1 unverhältnismäßig
erhöht, ohne dass der akute Schmerz (Ware schnell erfassen) das erfordert.
 
## Setup
 
```bash
git clone <repo-url>
cd bikedrop
flutter pub get
```
 
1. Supabase-Projekt anlegen, `items`-Tabelle + `item-photos`-Storage-Bucket
   gemäß Datenmodell im Design-Doc einrichten.
2. Row Level Security aktivieren (nur eingeloggte Mitarbeiter dürfen `items`
   lesen/schreiben).
3. `.env` mit Supabase-URL und Anon-Key befüllen (siehe `.env.example`).
4. Mitarbeiter-Accounts manuell im Supabase-Dashboard anlegen (kein
   Self-Signup in v1).
5. `flutter run`
## Testing
 
- **Repository-Layer**: Unit-Tests für `SupabaseRepository` (Item anlegen,
  laden, aktualisieren, löschen, Sichtbarkeit togglen) gegen einen gemockten
  Supabase-Client — kein echter Netzwerkzugriff.
- **Formular-Validierung**: Widget-Test für "Ware erfassen", der prüft, dass
  bei leeren Pflichtfeldern nicht gespeichert wird.
- Kein E2E-Test gegen ein echtes Supabase-Projekt in v1 — würde eine eigene
  Testumgebung erfordern, die für den aktuellen Umfang nicht nötig ist.
```bash
flutter test
```
 
## Scope & Roadmap
 
**v1 — aktueller Stand**
- Ein Standort, individuelle Mitarbeiter-Logins
- Artikel erfassen, anzeigen, bearbeiten, löschen
- Sichtbarkeits-Umschalter für die spätere Kunden-Website
- Kategorie als feste Dropdown-Auswahl
**v1.1 — nächste kleine Erweiterungen**
- Suche in der Übersicht (bei wachsender Artikelzahl wird reines Scrollen
  unpraktisch)
- Filter nach Kategorie
**v2 — geplant, aber bewusst noch nicht umgesetzt**
- Passwort-Reset-Flow (aktuell: Admin ändert Passwort manuell im
  Supabase-Dashboard — auf Dauer unpraktisch)
- Rollenmodell (wer darf löschen, wer nur erfassen) — relevant, sobald das
  Team wächst
- Bulk-Erfassung ohne Pflicht-Foto pro Artikel — bei großen Lieferungen ist
  Einzel-Erfassung mit Foto-Zwang langsam
- Mehrere Standorte
- Offline-Modus / Synchronisierung
- Soft-Delete / Papierkorb für gelöschte Artikel
**Bewusst nicht geplant (Out of Scope)**
- Self-Signup für Mitarbeiter (Accounts werden von Admin/Owner vergeben,
  passt zur Größe eines einzelnen Ladens)
---
 
*Folgeprojekt: [bikedrop-web] — Angular-Kundenwebsite auf derselben
Supabase-Datenbank.*