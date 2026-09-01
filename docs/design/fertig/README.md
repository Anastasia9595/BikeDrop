# Fertig — Screenshots der umgesetzten Screens

Der aktuelle Stand der Feature-Screens, direkt aus dem Code gerendert.
Anders als die Figma-Exporte eine Ebene darüber zeigen diese PNGs, wie die App
heute wirklich aussieht.

| Datei | Screen | Zustand |
| --- | --- | --- |
| `01-login-screen.png` | `LoginScreen` | leeres Formular |
| `02-overview-screen.png` | `OverviewScreen` | Bestand mit Seed-Artikeln |
| `03-overview-empty-state.png` | `OverviewScreen` | noch kein Bestand |
| `04-overview-no-search-results.png` | `OverviewScreen` | Suche ohne Treffer |
| `05-scanner-screen.png` | `ScannerScreen` | Demo-Kamera, kein aktiver Scan |
| `06-article-form-new.png` | `ArticleFormScreen` | neuer Artikel |
| `07-article-form-edit.png` | `ArticleFormScreen` | bestehender Artikel |

Frame: 390 × 872 Punkte bei devicePixelRatio 2 (= 780 × 1744 px), wie die
Figma-Exporte in `docs/design`. Die beiden Formular-Screens nutzen einen hohen
Frame (390 × 1300), damit alle Felder ohne Scrollen zu sehen sind.

## Neu erzeugen

```sh
flutter test test/design/capture_screens.dart --update-goldens
```

Der Generator liegt in `test/design/capture_screens.dart` und ist bewusst kein
`_test.dart` — `flutter test` ohne Pfad lässt ihn also aus.

## Zwei Abweichungen zur laufenden App

- **Schrift:** `AppTypography.fontFamily` ist `Archivo`, die Schrift liegt dem
  Projekt aber nicht bei (`assets/fonts` ist leer, keine `fonts:`-Sektion in
  `pubspec.yaml`). Die App fällt deshalb auf die System-Schrift zurück, die
  Screenshots auf Roboto.
- **Artikelbilder:** Die Seed-Artikel verweisen auf `picsum.photos`. Im
  Rendering gibt es kein Netz, die Kacheln zeigen daher den vorgesehenen
  Bild-Platzhalter.

`CaptureScreen` fehlt hier, weil der Screen aktuell nur ein `Placeholder()` ist.
