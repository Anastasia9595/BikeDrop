# BikeDrop Design System

Design-Sprache der BikeDrop-App (Flutter, Android/iOS) — extrahiert aus dem aktuellen App-Design. Basis: Modernist-Grundraster, angepasst für mobile Lagerarbeit (hoher Kontrast, große Tap-Ziele, ein dominanter CTA pro Screen).

## Typografie

- Schrift: **Archivo** (400/500/600/700/800), system-ui als Fallback
- Screen-Titel: 800 / 22–28px, letter-spacing -.02em
- Login-Wordmark: 800 / 44px, letter-spacing -.03em
- Body: 400 / 14–16px, line-height 1.4–1.55
- Feld-Label (Caps): 600 / 13px, letter-spacing .04em, Farbe `#605d5d`
- Section-Kicker (Caps): 800 / 11px, letter-spacing .16em
- Button-Label: 800 / 17px
- Zahlen in Listen (Stück): 800 / 18px

## Farben

| Rolle | Wert | Verwendung |
|---|---|---|
| Akzent (Signalrot) | `#ec3013` | Primär-CTA, aktive Icons, Fehler-Rand |
| Akzent hover | `#dd2b0f` | Button-Hover |
| Akzent pressed | `#ae1800` | Button-Press, Fehlertext |
| Akzent-Tint (Fehler-BG) | `#fff2ef` | Fehlerhinweis-Flächen |
| Text primär | `#201e1d` | Fließtext, Headlines |
| Text sekundär | `#605d5d` | Feld-Labels |
| Text tertiär | `#7d7979` | Metadaten, Hilfstext |
| Text quartär | `#9b9797` / `#bab6b6` | Platzhalter, inaktive Icons |
| Rand | `#d7d3d3` | Eingabefeld-Rahmen |
| Trennlinie | `#eae7e7` | Listen-Divider |
| Fläche neutral | `#f8f4f4` | App-Hintergrund, Zeilen-Hover |
| Fläche neutral dunkler | `#eae7e7` | Foto-Platzhalter, Icon-Kacheln |
| Weiß | `#fff` | Card-/Screen-Hintergrund |
| Snackbar-BG | `#201e1d` | Offline-Hinweis |
| Snackbar-Akzent | `#ff9783` | Snackbar-Icon/Link auf Dunkel |

### Kategorie-Badges (dezent, 5 Farben)

| Kategorie | Hintergrund | Text |
|---|---|---|
| Bremsen | `#ffe0d9` | `#7c1405` |
| Reifen | `#e2eefc` | `#1a4a8a` |
| E-Bike | `#e6f0e0` | `#33591f` |
| Zubehör | `#f3e8fb` | `#5c2a8a` |
| Pflege | `#fdf1cf` | `#8a5a00` |

## Abstände & Maße

- Screen-Padding horizontal: 20–24px
- Card-/Feld-Radius: 12–16px (Buttons 12–16px, Dialoge 22px, Foto-Kacheln 14–16px)
- Eingabefeld-Höhe: 54–56px, Rahmen 1.5px `#d7d3d3` (Fehler: `#ec3013`)
- Primär-Button-Höhe: 60px, radius 14–16px
- Tap-Ziel Minimum: **44×44px** (Icon-Buttons, Switches)
- Switch: 58×34px Spur, 28px Knopf
- Listenzeile: 12px vertikales Padding, 12px Gap zwischen Elementen
- Snackbar-Abstand vom unteren Rand: 136px (Platz für Speichern-Leiste)
- Divider/Header-Regel: 2px, `rgba(32,30,29,.4)`

## Komponenten

- **Primär-Button**: voll gefüllt Signalrot, weißer Text 800/17px, Label + Icon links-rechts verteilt (space-between), Schatten `0 8–10px 18–22px rgba(236,48,19,.28–.32)`, radius 14–16px
- **Sekundär-Button**: weiß, 1.5px Rand `#201e1d` oder `#d7d3d3`, Text 700/14px
- **Eingabefeld**: 1.5px Rand `#d7d3d3`, radius 12px, Label darüber in Caps
- **Switch**: an = Signalrot + Knopf rechts, aus = `#d7d3d3` + Knopf links; Card-Wrapper `#f8f4f4`, radius 14px
- **Kategorie-Badge**: 700/10px Caps, radius 6px, Padding 4px 7px, Tint-Paar aus Tabelle oben
- **Listenzeile**: Foto-Platzhalter 52px, zweizeiliger Name (line-clamp 2), Badge + Zeitangabe, Stückzahl rechtsbündig, Sichtbarkeits-Icon als 44px Tap-Ziel
- **Spalten-Header**: 700/11px Caps `#7d7979`, sitzt bündig auf Weiß, 2px Divider darunter
- **Snackbar**: `#201e1d`-BG, radius 14px, Icon + Text + Aktion, slide-up Animation, 136px vom unteren Rand
- **Löschdialog**: Overlay `rgba(32,30,29,.55)`, Card weiß radius 22px, Abbrechen (outline) + Löschen (gefüllt rot) nebeneinander
- **Fehlerhinweis (inline)**: `#fff2ef`-BG, 4px linker Rand `#ec3013`, Text `#ae1800`

## Zustände

- Hover: Buttons dunkleres Rot/Grau-Tint, Listenzeilen `#f8f4f4`
- Pressed: dunkelstes Rot `#ae1800`
- Fehler: Rand + Text in Signalrot/`#ae1800`, kein zusätzliches Icon-Rauschen
- Disabled: nicht im aktuellen Set definiert — bei Bedarf 45% Opacity (Modernist-Konvention) übernehmen

## Prinzipien

- Ein dominanter CTA pro Screen, Signalrot exklusiv für Primäraktion
- 44px Mindest-Tap-Ziel überall, auch bei Icon-only-Controls
- Hoher Kontrast für Werkstatt-/Lagerlicht: dunkles Ink auf Weiß, keine Grautöne unter `#7d7979` für lesbaren Text
- Dezente, unterscheidbare Kategorie-Farben statt reiner Text-Labels — Scannbarkeit ohne visuelles Rauschen
- Konsistente 12–16px Formsprache, keine scharfen Ecken, keine Schatten außer auf Primär-CTA und Overlays
