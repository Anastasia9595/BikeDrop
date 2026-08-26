# EAN-Validierung im Scanner

## Ziel

Der Scanner darf nur noch gültige Produkt-Barcodes in die App lassen. Heute reicht
`MobileScannerAdapter` jeden erkannten `rawValue` ungefiltert weiter — auch den Inhalt
eines QR-Codes. Dieser Wert landet ungeprüft in der Lookup-Kaskade und im
Artikelformular.

Zusätzlich geht die gescannte EAN im Unbekannt-Fall verloren: Kennen weder Lager noch
Katalog den Code, öffnet das Formular vollständig leer und der Nutzer müsste die Nummer
abtippen.

## Ansatz

Zwei Kontrollpunkte statt verstreuter Prüfungen:

1. **Format-Filter am Adapter** — die Kamera meldet nur noch EAN-13, EAN-8 und UPC-A.
2. **Prüfziffern-Torwächter im `ScannerScreen`** — jeder Scan, echt wie simuliert, läuft
   durch `_handleScannedEan`. Dort wird validiert und normalisiert, bevor `onEanScanned`
   überhaupt aufgerufen wird.

Dadurch bekommt `onEanScanned` garantiert eine gültige, 13-stellige EAN. Die
Lookup-Kaskade und alle künftigen Aufrufer (z.B. Wareneingang) müssen selbst nichts
prüfen.

## Änderungen

### 1. lib/core/ean.dart (neu)

Reine Funktion ohne Flutter-Abhängigkeit, nach dem Muster von `lib/core/article_image.dart`.
Validiert und normalisiert in einem Schritt, weil jeder Aufrufer beides braucht:

```dart
String? normalizeScannedEan(String raw)
```

Liefert den Code in kanonischer Form oder `null`. Abgelehnt wird: leer, Nicht-Ziffern,
Länge ungleich 8/12/13, falsche Prüfziffer.

Ein UPC-A (12 Stellen) wird mit führender Null zur EAN-13; die Prüfziffer bleibt dabei
unverändert gültig, das ist der GS1-Standardweg. EAN-8 bleibt achtstellig.

Die Prüfziffernrechnung läuft von rechts mit alternierenden Gewichten 3, 1, 3, 1. So gilt
eine Formel für alle drei Längen statt drei Sonderfälle.

Gegengerechnet an den Demo-EANs: `4029876501233` → Summe 97 → Prüfziffer 3;
`4711234567899` → Summe 121 → 9; `978020137962` → Summe 118 → 2.

### 2. lib/repository/mobile_scanner_adapter_repository.dart

```dart
final _controller = MobileScannerController(
  formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA],
);
```

Schließt den QR-Code-Durchstich. API verifiziert gegen mobile_scanner 7.4.0.

### 3. lib/features/scanner_screen.dart

`_handleScannedEan` wird zum Torwächter:

```dart
Future<void> _handleScannedEan(String raw) async {
  final ean = normalizeScannedEan(raw);
  if (ean == null) {
    if (!mounted) return;
    AppSnackbar.show(context, 'Ungültiger Barcode – bitte erneut scannen');
    return;
  }
  await widget.onEanScanned(context, ref, ean);
}
```

Der Scanner läuft weiter, der Nutzer bleibt auf dem Screen und kann sofort neu scannen.

### 4. lib/features/article_form_screen.dart

Neuer optionaler Parameter `scannedEan`, als letztes Glied der Vorbefüllungskette:

```dart
text: article?.ean ?? catalog?.ean ?? widget.scannedEan ?? '',
```

`article` und `catalogArticle` behalten Vorrang. Alle übrigen Felder bleiben leer — den
Rest trägt der Nutzer ein.

### 5. lib/features/overview_screen.dart

- `onEanScanned` reicht im Unbekannt-Fall `scannedEan: ean` ans Formular durch.
- Vierte Demo-Option, damit der Fehlerpfad im Simulator überhaupt erreichbar ist —
  die drei bestehenden EANs sind alle gültig:

```dart
DemoScanOption(
  ean: '4029876501234',        // gleiche EAN, Pruefziffer 4 statt 3
  label: 'Ungültigen Barcode simulieren',
  subtitle: 'EAN 4029876501234 · falsche Prüfziffer',
  icon: Symbols.error_rounded,
),
```

## Datenfluss

```
Kamera --formats:[ean13,ean8,upcA]--> rawValue
                                         |
                        normalizeScannedEan(raw)
                          |                    |
                       null                gueltig, 13-stellig
                          |                    |
                   AppSnackbar          Lager? --ja--> Formular(article)
                   Scanner laeuft         |nein
                   weiter                Katalog? --ja--> Formular(catalogArticle)
                                          |nein
                                         Formular(scannedEan: ean)
                                         -> Feld "Artikelnummer" gefuellt
```

## Tests

| Datei | Deckt ab |
|---|---|
| `test/core/ean_test.dart` (neu) | EAN-13 gültig, EAN-8 gültig, UPC-A wird 13-stellig, falsche Prüfziffer, Buchstaben, falsche Länge, Leerstring, Whitespace |
| `test/features/scanner_screen_test.dart` | ungültiger Scan ruft `onEanScanned` nicht auf und zeigt die Snackbar; UPC-A-Scan liefert dem Callback 13 Stellen |
| `test/features/article_form_catalog_test.dart` | `scannedEan` füllt „Artikelnummer" bei sonst leerem Formular; `article` und `catalogArticle` haben Vorrang |

## Bewusste Konsequenzen

Demo-Option 3 (`978020137962`, UPC-A) erscheint durch die Normalisierung als
`0978020137962` im Formular. Das ist korrektes Verhalten und zeigt die Normalisierung
gleich mit; der Subtitle behält die zwölfstellige Schreibweise.

## Out of Scope

Das Formularfeld heißt „Artikelnummer", enthält aber die EAN. Ob Artikelnummer und EAN
fachlich zwei Felder sein müssen, ist eine eigene Entscheidung und wird hier nicht
angefasst.

Eine externe Produktdatenbank als vierte Lookup-Stufe hinter dem Katalog ist nicht Teil
dieser Änderung.

---

# Nachtrag: Validierung im Artikelformular

## Ziel

Auch eine von Hand eingegebene oder bearbeitete Artikelnummer wird geprüft. Ist sie
ungültig, wird das Feld als Fehler markiert und ein Fehlertext darunter angezeigt.

## Entscheidung

Getippt und gescannt gehen **denselben Weg**: Das Feld nutzt dieselbe Regel wie der
Scanner (`normalizeScannedEan`, akzeptiert EAN-8, UPC-A und EAN-13). Damit kann ein Scan
das Formular nie in einen Fehlerzustand versetzen, und es gibt genau eine Regel in der
ganzen App.

Beim Speichern wird derselbe Normalisierungsschritt angewandt wie beim Scan. Ein von Hand
getippter UPC-A landet dadurch 13-stellig im Bestand — genau wie derselbe Code über die
Kamera.

## Änderungen

Alle in `lib/features/article_form_screen.dart`, gespiegelt am bestehenden Muster von
`_maxQuantityError`:

1. **`_articleNumberError`** (neu) — Getter, der `null` liefert bei leerem Feld (leer
   heißt „noch nicht ausgefüllt", nicht „falsch"; die Pflicht erzwingt `_canSave`) und
   sonst gegen `normalizeScannedEan` prüft.
2. **`errorText: _articleNumberError`** am Feld „Artikelnummer". `AppTextField` färbt den
   Rahmen und rendert den Text darunter — am Design System ist nichts zu ändern.
3. **`_articleNumberError == null`** ergänzt `_canSave`, sperrt also das Speichern.
4. **`_save()`** normalisiert vor dem Schreiben: `normalizeScannedEan(raw) ?? raw`.

Die Prüfung läuft bei jedem Tastendruck, weil das Feld bereits
`onChanged: (_) => setState(() {})` hatte.

## Verhalten

| Eingabe | Feld | Speichern |
|---|---|---|
| leer | neutral, kein Fehlertext | gesperrt (Pflichtfeld) |
| `40298765012` (unvollständig) | rot + Fehlertext | gesperrt |
| `4029876501234` (Prüfziffer falsch) | rot + Fehlertext | gesperrt |
| `4029876501233` (EAN-13) | neutral | frei |
| `96385074` (EAN-8) | neutral | frei |
| `978020137962` (UPC-A) | neutral | frei, gespeichert als `0978020137962` |

## Tests

Ergänzt in `test/features/article_form_can_save_test.dart` (sechs Fälle, siehe Tabelle).
Der Test für das Speichern braucht `tester.ensureVisible`, weil der Speichern-Button
unterhalb des Test-Viewports liegt.
