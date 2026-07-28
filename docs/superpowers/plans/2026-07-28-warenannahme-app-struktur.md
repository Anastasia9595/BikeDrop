# Warenannahme-App — Struktur- & Architekturplan

> **Hinweis:** Dies ist bewusst kein code-vollständiger TDD-Ausführungsplan
> (siehe superpowers:writing-plans / superpowers:executing-plans). Er legt nur
> Ordnerstruktur, Verantwortlichkeiten und grobe Schnittstellen (Klassen-/
> Methodennamen, Parameter, Rückgabetypen) fest. Die Implementierung inkl.
> Tests schreibt der Nutzer selbst. Grundlage:
> `docs/superpowers/specs/2026-07-26-warenannahme-app-design.md`.

**Ziel:** Grundgerüst für die Warenannahme-Flutter-App (Login, Übersicht, Ware
erfassen, Artikel-Detail) mit Supabase-Backend, Riverpod + Repository-Pattern.

**Architektur:** Eine einzige `SupabaseRepository`-Klasse kapselt jeglichen
Zugriff auf Supabase (Auth + Postgres + Storage). Riverpod-Provider reichen
Auth-Status und Artikel-Liste an die UI weiter. Screens greifen nie direkt auf
Supabase zu, nur über Provider → Repository.

**Tech-Stack:** Flutter, `supabase_flutter`, `flutter_riverpod`, `image_picker`
(Kamera/Galerie für Artikelfotos).

## Global Constraints (aus dem Spec)

- v1-Umfang: ein Standort, individuelle Mitarbeiter-Logins, durchgehende
  Internetverbindung vorausgesetzt — **kein Offline-Modus**.
- **Ein** `SupabaseRepository` ist die einzige Stelle, die mit Supabase
  spricht (kein separates Data-Source-Layer, keine Aufteilung in
  Auth-/Item-Repository — laut Spec explizit eine Klasse).
- Kein Self-Signup in der App; Mitarbeiter-Accounts werden manuell im
  Supabase-Dashboard angelegt.
- RLS: Nur eingeloggte Mitarbeiter (`auth.uid() is not null`) dürfen `items`
  lesen/schreiben.
- Foto muss erfolgreich hochgeladen sein, **bevor** der `items`-Datensatz
  angelegt wird — kein „Artikel ohne Foto"-Zustand.
- Pflichtfelder: Name, Menge, Kategorie, Preis, Lieferant, Foto — Inline-
  Validierung vor dem Absenden.
- Verbindungsfehler: Snackbar-Fehlermeldung, Formular-Eingaben bleiben
  erhalten, kein Datenverlust.
- Login-Fehler: unspezifische Meldung („E-Mail oder Passwort falsch").
- Löschen: Bestätigungsdialog, kein Soft-Delete/Papierkorb.
- Tests: Repository-Unit-Tests gegen gemockten Supabase-Client (kein echtes
  Netzwerk); Widget-Test für Pflichtfeld-Validierung im „Ware erfassen"-
  Formular; kein E2E gegen echtes Supabase-Projekt in v1.

---

## Ordnerstruktur

```
lib/
  main.dart                          # App-Bootstrap, Supabase.initialize, ProviderScope, Routing
  core/
    supabase_config.dart             # Supabase-URL/Anon-Key, Storage-Bucket-Name
  models/
    item.dart                        # Item-Datenmodell
  repository/
    supabase_repository.dart         # einzige Schnittstelle zu Supabase (Auth + Items + Storage)
  providers/
    supabase_providers.dart          # Provider<SupabaseClient>, Provider<SupabaseRepository>
    auth_provider.dart               # Auth-Status für die UI
    items_provider.dart              # Artikel-Liste + CRUD-Aktionen für die UI
  screens/
    login_screen.dart
    overview_screen.dart             # "Übersicht"
    capture_screen.dart              # "Ware erfassen"
    item_detail_screen.dart          # "Artikel-Detail"
  widgets/
    item_list_tile.dart              # eine Zeile in der Übersicht (Thumbnail, Name, Menge, Sichtbarkeits-Icon)

supabase/
  migrations/
    0001_items.sql                   # items-Tabelle + RLS-Policies

test/
  repository/
    supabase_repository_test.dart
  screens/
    capture_screen_test.dart
```

**Warum so geschnitten:** `repository/` ist bewusst eine einzelne Datei (kein
`data/` + `repository/`-Split wie in einer früheren, verworfenen Version) —
das Spec verlangt explizit „einzige Stelle". `providers/` ist von
`repository/` getrennt, weil Provider reine Riverpod-Verdrahtung sind und sich
unabhängig von der Repository-Logik ändern können. `widgets/` existiert nur
für Bausteine, die in mehr als einem Screen vorkämen — aktuell nur
`item_list_tile.dart`; falls sich beim Bauen keine Wiederverwendung ergibt,
kann der Code auch direkt in `overview_screen.dart` bleiben.

---

## Bausteine

### 1. Projekt-Setup: Dependencies & Supabase-Konfiguration

**Dateien:**
- Ändern: `pubspec.yaml` (Dependencies ergänzen)
- Erstellen: `lib/core/supabase_config.dart`

**Verantwortlichkeit:** Legt fest, welche Pakete das Projekt braucht und wo
die Supabase-Zugangsdaten herkommen (z. B. aus `--dart-define` oder einer
lokalen, nicht eingecheckten Config — Secrets dürfen nicht ins Repo).

**Dependencies:** `supabase_flutter`, `flutter_riverpod`, `image_picker`.
Dev: ein Mocking-Paket für die Repository-Tests (z. B. `mocktail`).

**Grobe Schnittstelle:**
```dart
class SupabaseConfig {
  static const String url = ...;
  static const String anonKey = ...;
  static const String itemPhotosBucket = 'item-photos';
}
```

---

### 2. Datenmodell: `Item`

**Dateien:** Erstellen: `lib/models/item.dart`

**Verantwortlichkeit:** Bildet die `items`-Tabelle als Dart-Objekt ab
(siehe Spaltenliste im Spec) und übernimmt (De-)Serialisierung von/zu
Supabase-Maps.

**Grobe Schnittstelle:**
```dart
class Item {
  final String id;
  final String name;
  final int quantity;
  final String category;
  final double price;
  final String supplier;
  final String photoUrl;
  final bool visibleToCustomers;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory Item.fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toInsertMap();   // ohne id/createdAt/updatedAt
  Map<String, dynamic> toUpdateMap();   // nur editierbare Felder
  Item copyWith({...});
}
```

---

### 3. Supabase-Migration: `items`-Tabelle & RLS

**Dateien:** Erstellen: `supabase/migrations/0001_items.sql`

**Verantwortlichkeit:** Legt die Tabelle exakt nach Spaltenliste im Spec an
(siehe Design-Doc, Abschnitt „Datenmodell") und aktiviert Row Level Security.

**Anforderungen (kein fertiges SQL, nur die Vorgaben):**
- Spalten wie im Spec: `id uuid PK`, `name text`, `quantity integer`,
  `category text`, `price numeric`, `supplier text`, `photo_url text`,
  `visible_to_customers boolean default false`,
  `created_by uuid FK → auth.users`, `created_at timestamptz default now()`,
  `updated_at timestamptz`.
- RLS aktiviert; Policy erlaubt SELECT/INSERT/UPDATE/DELETE nur wenn
  `auth.uid() is not null`.
- Storage-Bucket `item-photos` (privat oder mit vergleichbarer Policy, damit
  nur eingeloggte Mitarbeiter hochladen können).

---

### 4. `SupabaseRepository`

**Dateien:**
- Erstellen: `lib/repository/supabase_repository.dart`
- Test: `test/repository/supabase_repository_test.dart`

**Verantwortlichkeit:** Einzige Klasse, die `SupabaseClient` anfasst. Bündelt
Auth, Items-CRUD, Sichtbarkeits-Umschaltung und Foto-Upload. Wirft bei
Netzwerk-/Supabase-Fehlern eine Exception, die die aufrufende Seite (Provider)
in eine Snackbar-Meldung übersetzt — die Repository-Methode selbst zeigt
nichts an.

**Grobe Schnittstelle:**
```dart
class SupabaseRepository {
  SupabaseRepository(this._client);
  final SupabaseClient _client;

  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Stream<AuthState> get authStateChanges;

  Future<List<Item>> fetchItems();                          // neueste zuerst
  Future<Item> createItem({required Item item, required File photo});
  Future<Item> updateItem(Item item);
  Future<void> deleteItem(String id);
  Future<void> setVisibility({required String id, required bool visible});
}
```

**Was getestet werden sollte (Unit-Tests, `SupabaseClient` gemockt):**
- `signIn` erfolgreich vs. falsche Zugangsdaten (Exception).
- `fetchItems` gibt Liste sortiert nach `created_at desc` zurück.
- `createItem`: Foto-Upload wird vor dem Insert aufgerufen; schlägt der
  Upload fehl, wird kein Insert versucht.
- `updateItem` setzt `updated_at`.
- `deleteItem` und `setVisibility` rufen die richtigen Client-Methoden mit
  den richtigen Parametern auf.

---

### 5. Riverpod-Provider: Supabase-Zugriff & Auth

**Dateien:**
- Erstellen: `lib/providers/supabase_providers.dart`
- Erstellen: `lib/providers/auth_provider.dart`

**Verantwortlichkeit:** Stellt `SupabaseClient`/`SupabaseRepository` als
Provider bereit und übersetzt den Auth-Status in einen Zustand, den die UI
konsumieren kann (eingeloggt / ausgeloggt / lädt / Fehler).

**Grobe Schnittstelle:**
```dart
final supabaseClientProvider = Provider<SupabaseClient>((ref) => ...);
final supabaseRepositoryProvider = Provider<SupabaseRepository>((ref) => ...);

// z. B. als StreamProvider auf Basis von repository.authStateChanges,
// oder als eigener StateNotifier — Entscheidung liegt beim Implementierer.
final authStateProvider = StreamProvider<AuthState>((ref) => ...);
```

---

### 6. Riverpod-Provider: Artikel-Liste

**Dateien:** Erstellen: `lib/providers/items_provider.dart`

**Verantwortlichkeit:** Hält die aktuelle Artikel-Liste im UI-Zustand,
bietet Aktionen für Neuladen/Erstellen/Aktualisieren/Löschen/Sichtbarkeit,
delegiert an `SupabaseRepository`.

**Grobe Schnittstelle:**
```dart
class ItemsNotifier extends AsyncNotifier<List<Item>> {
  @override
  Future<List<Item>> build();               // initiales Laden

  Future<void> refresh();                    // Pull-to-refresh
  Future<void> addItem({required Item item, required File photo});
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);
  Future<void> toggleVisibility(String id, bool visible);
}

final itemsProvider = AsyncNotifierProvider<ItemsNotifier, List<Item>>(...);
```

---

### 7. `LoginScreen`

**Dateien:** Erstellen: `lib/screens/login_screen.dart`

**Verantwortlichkeit:** E-Mail/Passwort-Formular. Ruft bei „Anmelden"
`authProvider`/Repository-`signIn` auf. Bei Fehler: unspezifische
Fehlermeldung anzeigen. Bei Erfolg: Navigation zur Übersicht (die eigentliche
Navigation kann auch zentral in `main.dart` anhand von `authStateProvider`
gesteuert werden — Implementierungsdetail, hier offen gelassen).

**Zu berücksichtigen:** Ladezustand während des Anmeldevorgangs (Button
deaktivieren/Spinner), damit kein Doppel-Submit passiert.

---

### 8. `OverviewScreen` + `ItemListTile`

**Dateien:**
- Erstellen: `lib/screens/overview_screen.dart`
- Erstellen: `lib/widgets/item_list_tile.dart`

**Verantwortlichkeit:** Zeigt `itemsProvider`-Liste, neueste zuerst.
Pull-to-refresh → `ItemsNotifier.refresh()`. Tap auf Zeile → Navigation zu
`ItemDetailScreen` mit dem jeweiligen `Item`. Button/FAB → `CaptureScreen`.

`ItemListTile` zeigt Foto-Thumbnail (aus `photoUrl`), Name, Menge,
Sichtbarkeits-Icon (offenes/geschlossenes Auge je nach
`visibleToCustomers`).

---

### 9. `CaptureScreen` („Ware erfassen")

**Dateien:** Erstellen: `lib/screens/capture_screen.dart`

**Verantwortlichkeit:** Formular mit Name, Menge, Kategorie, Preis,
Lieferant (alle Pflichtfelder) sowie Foto-Auswahl (Kamera oder Galerie via
`image_picker`, ebenfalls Pflichtfeld). Inline-Validierung: kein Speichern
möglich, solange ein Pflichtfeld leer/kein Foto gewählt ist. „Speichern"
ruft `ItemsNotifier.addItem(...)` auf; bei Fehler bleiben alle Eingaben im
Formular erhalten und eine Snackbar erscheint; bei Erfolg zurück zur
Übersicht mit Erfolgsmeldung.

**Was getestet werden sollte (Widget-Test):**
- Absenden mit leeren Pflichtfeldern löst keinen Speicher-Aufruf aus und
  zeigt Feldfehler an.

---

### 10. `ItemDetailScreen`

**Dateien:** Erstellen: `lib/screens/item_detail_screen.dart`

**Verantwortlichkeit:** Formular vorausgefüllt mit den Werten des
übergebenen `Item`, alle Felder editierbar. Sichtbarkeits-Switch direkt im
Screen (ruft `toggleVisibility`). „Speichern" ruft
`ItemsNotifier.updateItem(...)` auf. Löschen-Button öffnet
Bestätigungsdialog, erst danach `ItemsNotifier.deleteItem(...)`.

---

### 11. Routing/Verdrahtung in `main.dart`

**Dateien:** Ändern: `lib/main.dart`

**Verantwortlichkeit:** `Supabase.initialize(...)` beim Start, `ProviderScope`
um die App, Einstiegspunkt anhand `authStateProvider` (eingeloggt →
`OverviewScreen`, sonst → `LoginScreen`). Restliche Navigation
(Übersicht → Detail/Erfassen) erfolgt aus den jeweiligen Screens heraus.

---

## Reihenfolge / Abhängigkeiten

1 → 2 → 3 (unabhängig von 2, kann parallel) → 4 (braucht 1, 2) → 5 (braucht 1, 4)
→ 6 (braucht 4, 5) → 7 (braucht 5) → 8 (braucht 6) → 9 (braucht 6) → 10 (braucht 6)
→ 11 (braucht 5, 7, 8).

## Spec-Abdeckung (Selbstcheck)

- Login/Auth (E-Mail+Passwort, unspezifischer Fehler): Baustein 4, 5, 7. ✓
- Übersicht (Liste, Thumbnail, Sichtbarkeits-Icon, Pull-to-refresh, Navigation): Baustein 6, 8. ✓
- Ware erfassen (Pflichtfelder, Foto vor Insert, Fehler behält Eingaben): Baustein 4, 6, 9. ✓
- Artikel-Detail (editierbar, Sichtbarkeits-Switch, Löschen mit Bestätigung): Baustein 6, 10. ✓
- Datenmodell/RLS: Baustein 2, 3. ✓
- Repository-Pattern mit einziger Supabase-Kontaktstelle: Baustein 4. ✓
- Testing-Anforderungen (Repository-Unit-Tests, Formular-Validierungs-Test): in Baustein 4 und 9 als Testfälle benannt. ✓
- Out-of-Scope-Punkte (Angular-Website, Mehrstandort, Offline, Self-Signup, Soft-Delete) bewusst nicht abgedeckt. ✓
