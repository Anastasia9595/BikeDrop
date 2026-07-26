# Warenannahme-App (BikeDrop) — Design

**Datum:** 2026-07-26
**Status:** Genehmigt

## Kontext & Ziel

Mitarbeiter sollen neu eingetroffene Ware schnell über eine Flutter-App erfassen und
den aktuellen Warenbestand überblicken können. Später sollen Kunden neu eingetroffene
Produkte auf einer separaten Angular-Website sehen. Dieses Dokument beschreibt nur die
**Flutter-App und das dafür nötige Backend** — die Angular-Kundenwebsite ist ein
eigenständiges Folgeprojekt mit eigenem Spec.

**Umfang v1:** ein Standort, individuelle Mitarbeiter-Logins, durchgehende
Internetverbindung vorausgesetzt (kein Offline-Modus).

## Architektur

- **Flutter-App** (Android + iOS) für Mitarbeiter: Login, Ware erfassen, Übersicht,
  Artikel-Detail.
- **Supabase** als Backend: Postgres-Datenbank, Auth (E-Mail/Passwort), Storage
  (Produktfotos). Kein eigener Server nötig.
- **Angular-Kundenwebsite** (nicht Teil dieses Designs): liest später direkt aus
  derselben Supabase-Datenbank, eingeschränkt auf sichtbare Artikel.

### App-Struktur

- **Riverpod + Repository-Pattern.**
- `SupabaseRepository`: einzige Stelle, die mit Supabase spricht (Login, Artikel
  anlegen/laden/aktualisieren/löschen, Sichtbarkeit umschalten, Foto hochladen).
- Riverpod-Provider stellen Auth-Status und Artikel-Liste der UI bereit.
- Begründung: testbar (Repository mockbar), aktueller Flutter/Supabase-Standard,
  passender Aufwand für eine App dieser Größe (4 Screens, ein Standort). Provider
  wäre zwar einfacher, aber weniger zukunftsfähig; BLoC wäre für diesen Umfang zu
  viel Ceremony.

## Datenmodell (Supabase Postgres)

**`employees`:** kein eigenes Tabellen-Design — verwaltet über Supabase Auth
(`auth.users`), da nur ein Standort und keine Rollen-Unterscheidung nötig ist.
Mitarbeiter-Accounts werden manuell im Supabase-Dashboard angelegt (kein
Self-Signup in der App, v1).

**`items`** (Warenerfassung):

| Spalte | Typ | Hinweis |
|---|---|---|
| id | uuid, PK | |
| name | text | |
| quantity | integer | |
| category | text | |
| price | numeric | Einkaufspreis |
| supplier | text | |
| photo_url | text | Pfad im Supabase-Storage-Bucket `item-photos` |
| visible_to_customers | boolean, default false | Sichtbarkeits-Status für Kunden-Website |
| created_by | uuid, FK → auth.users | wer hat den Artikel erfasst |
| created_at | timestamptz, default now() | |
| updated_at | timestamptz | bei Bearbeitung aktualisiert |

**Row Level Security:** Nur eingeloggte Mitarbeiter (`auth.uid() is not null`)
dürfen `items` lesen/schreiben. Die spätere Angular-Website erhält eine eigene,
restriktivere Policy (nur `visible_to_customers = true`); ob Preis-/
Lieferantenspalten dort sichtbar sein sollen, wird im Angular-Spec entschieden.

## Screens & User Flow

**Login**
- E-Mail + Passwort (Supabase Auth). Kein Self-Signup in der App.
- Bei Erfolg → Übersicht.

**Übersicht** (erster Screen nach Login)
- Liste aller Artikel, neueste zuerst. Jede Zeile: Foto-Thumbnail, Name, Menge,
  Sichtbarkeits-Icon (Auge offen/geschlossen).
- Tippen auf eine Zeile → Artikel-Detail.
- Pull-to-refresh zum Neuladen.
- Button zu "Ware erfassen".

**Ware erfassen**
- Formular: Name*, Menge*, Kategorie*, Preis*, Lieferant*, Foto (Kamera oder
  Galerie, Pflichtfeld).
- "Speichern" lädt zuerst das Foto in Storage hoch, legt danach die Zeile in
  `items` an (`visible_to_customers` startet als `false`). Zurück zur Übersicht
  mit Erfolgsmeldung.

**Artikel-Detail** (via Tippen aus der Übersicht)
- Alle Felder editierbar; "Speichern" aktualisiert `items` und setzt `updated_at`.
- Sichtbarkeits-Umschalter (Switch) direkt hier.
- Löschen-Button mit Bestätigungsdialog (kein Soft-Delete/Papierkorb in v1).

## Fehlerbehandlung

- **Kein Internet / Supabase nicht erreichbar:** Snackbar-Fehlermeldung ("Keine
  Verbindung, bitte erneut versuchen"), Formular-Eingaben bleiben erhalten, kein
  Datenverlust bei fehlgeschlagenem Speichern.
- **Foto-Upload schlägt fehl:** Artikel wird nicht angelegt, bevor nicht sowohl
  Foto als auch Datensatz erfolgreich gespeichert sind — kein "Artikel ohne
  Foto"-Zustand.
- **Pflichtfelder leer:** Inline-Validierung im Formular vor dem Absenden,
  Fehler wird unter dem jeweiligen Feld angezeigt.
- **Login fehlgeschlagen:** Klare, aber unspezifische Fehlermeldung ("E-Mail
  oder Passwort falsch") — kein Hinweis, welches der beiden Felder falsch ist.
- **Löschen:** Bestätigungsdialog verhindert versehentliches Löschen.

## Testing

- **Repository-Layer:** Unit-Tests für `SupabaseRepository`-Methoden (Item
  anlegen, laden, aktualisieren, löschen, Sichtbarkeit togglen) gegen einen
  gemockten Supabase-Client — kein echter Netzwerkzugriff.
- **Formular-Validierung:** Widget-Test für "Ware erfassen", der prüft, dass bei
  leeren Pflichtfeldern nicht gespeichert wird.
- **Kein E2E/Integrationstest gegen ein echtes Supabase-Projekt in v1** — würde
  eine eigene Testumgebung erfordern, die für den aktuellen Umfang nicht nötig
  ist.

## Out of Scope (v1)

- Angular-Kundenwebsite (eigenes Folgeprojekt/Spec).
- Mehrere Standorte.
- Offline-Modus / Synchronisierung.
- Self-Signup / Rollen & Rechte für Mitarbeiter.
- Soft-Delete / Papierkorb für gelöschte Artikel.
