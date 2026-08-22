# Riverpod-Integration

## Ziel

Riverpod als State-Management-Grundlage einführen und in `main.dart` einbinden, mit einem Provider für die bestehende `ArticleRepository`-Abstraktion.

## Ansatz

Plain `flutter_riverpod` (kein Codegen, kein `build_runner`) — passend zum aktuellen, einfachen Projektstand.

## Umfang

Nur ein Repository-Provider. Keine UI-Screens werden verändert.

## Änderungen

1. **pubspec.yaml** — `flutter_riverpod` als Dependency hinzufügen.
2. **lib/providers/article_repository_provider.dart** (neu) — `Provider<ArticleRepository>`, der aktuell eine `MockArticleRepository`-Instanz liefert. Austauschbar per Override, sobald eine echte Implementierung (z.B. Supabase) existiert.
3. **lib/main.dart** — `runApp(const MyApp())` → `runApp(const ProviderScope(child: MyApp()))`. `MyApp` bleibt ein `StatelessWidget`, da aktuell kein Screen den Provider konsumiert.

## Out of Scope

Die bestehenden leeren Stub-Dateien (`lib/providers/items_provider.dart`, `lib/providers/auth_provider.dart`, `lib/providers/supabase_providers.dart`, `lib/repository/supabase_repository.dart`, `lib/core/supabase_config.dart`) gehören zu einem späteren Supabase-Feature und werden nicht angefasst.

## Tests

Kein neuer Testbedarf — reine Verkabelung ohne Verhaltensänderung. Bestehende Tests (`test/widget_test.dart`) müssen weiterhin grün bleiben.
