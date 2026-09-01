/// Rendert die Feature-Screens als PNG nach `docs/design/fertig/`.
///
/// Bewusst KEIN `_test.dart`: Die Datei gehoert nicht zur Testsuite, sondern
/// ist ein Generator. Aufruf aus dem Projektwurzelverzeichnis:
///
/// ```sh
/// flutter test test/design/capture_screens.dart --update-goldens
/// ```
///
/// Frame-Groesse entspricht den vorhandenen Figma-Exporten in `docs/design`:
/// 390 x 872 logische Punkte bei devicePixelRatio 2 = 780 x 1744 Pixel.
library;

import 'dart:convert';
import 'dart:io';

import 'package:bikedrop/design_system/design_system.dart';
import 'package:bikedrop/features/article_form_screen.dart';
import 'package:bikedrop/features/login_screen.dart';
import 'package:bikedrop/features/overview_screen.dart';
import 'package:bikedrop/features/scanner_screen.dart';
import 'package:bikedrop/interface/article_interface.dart';
import 'package:bikedrop/l10n/app_localizations.dart';
import 'package:bikedrop/models/article.dart';
import 'package:bikedrop/models/demoscanoption.dart';
import 'package:bikedrop/providers/article_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

const _outputDir = '../../docs/design/fertig';

/// Telefon-Frame wie die bestehenden Design-Exporte.
const _phone = Size(390, 872);

/// Hoher Frame fuer das Formular: zeigt alle Felder ohne Scrollen.
const _tallForm = Size(390, 1300);

const _devicePixelRatio = 2.0;

/// Liest die Seed-Artikel direkt von der Platte statt ueber `rootBundle` —
/// so ist die Liste im Screenshot dieselbe wie in der App, aber synchron da.
class _SeedArticleRepository implements ArticleRepository {
  _SeedArticleRepository(this.articles);

  factory _SeedArticleRepository.fromSeed() {
    final raw = File('assets/data/seed_articles.json').readAsStringSync();
    final articles = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        // Die Seed-Bilder liegen auf picsum.photos: im Test gibt es kein Netz,
        // die Kacheln zeigen deshalb den vorgesehenen Platzhalter.
        .map((a) => a.copyWith(imageUrl: null))
        .toList();
    return _SeedArticleRepository(articles);
  }

  final List<Article> articles;

  @override
  Future<List<Article>> getArticles() async => articles;

  @override
  Future<List<Article>> searchArticlesByName(String query) async =>
      query.isEmpty
      ? articles
      : articles
            .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

  @override
  Future<List<String>> getSuppliers() async =>
      articles.map((a) => a.supplier).whereType<String>().toSet().toList();

  @override
  Future<Article?> getArticleByEan(String ean) async =>
      articles.where((a) => a.ean == ean).firstOrNull;

  @override
  Future<Article?> getArticleById(String id) async =>
      articles.where((a) => a.id == id).firstOrNull;

  @override
  Future<Article> createArticle(Article article) async => article;

  @override
  Future<Article> updateArticle(Article article) async => article;

  @override
  Future<Article> changeQuantity(String id, int quantity) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteArticle(String id) async => throw UnimplementedError();
}

/// Ohne echte Fonts rendert `flutter test` jeden Buchstaben als Kasten.
/// Archivo liegt dem Projekt nicht bei — die App faellt auf die
/// System-Schrift zurueck, hier steht dafuer Roboto ein.
Future<void> _loadFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) {
    throw StateError('FLUTTER_ROOT fehlt — bitte ueber `flutter test` starten');
  }
  final materialFonts = Directory(
    '$flutterRoot/bin/cache/artifacts/material_fonts',
  );

  await _load('Archivo', [
    '${materialFonts.path}/Roboto-Regular.ttf',
    '${materialFonts.path}/Roboto-Medium.ttf',
    '${materialFonts.path}/Roboto-Bold.ttf',
    '${materialFonts.path}/Roboto-Black.ttf',
  ]);
  await _load('Roboto', ['${materialFonts.path}/Roboto-Regular.ttf']);
  await _load('MaterialIcons', [
    '${materialFonts.path}/MaterialIcons-Regular.otf',
  ]);

  final symbols = _packageRoot('material_symbols_icons');
  for (final variant in const ['Outlined', 'Rounded', 'Sharp']) {
    await _load(
      'packages/material_symbols_icons/MaterialSymbols$variant',
      ['$symbols/lib/fonts/MaterialSymbols$variant.ttf'],
    );
  }
}

Future<void> _load(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

/// Pfad eines Pakets aus dem package_config — der pub-cache liegt nicht
/// auf jedem Rechner an derselben Stelle.
String _packageRoot(String package) {
  final config =
      jsonDecode(File('.dart_tool/package_config.json').readAsStringSync())
          as Map<String, dynamic>;
  final entry = (config['packages'] as List<dynamic>).firstWhere(
    (p) => (p as Map<String, dynamic>)['name'] == package,
  );
  return File.fromUri(
    Uri.parse((entry as Map<String, dynamic>)['rootUri'] as String),
  ).path;
}

/// Baut den Screen in derselben App-Huelle wie `main.dart` und schreibt ihn
/// als PNG.
Future<void> _capture(
  WidgetTester tester,
  String name,
  Widget screen, {
  List<Override> overrides = const [],
  Size size = _phone,
}) async {
  tester.view
    ..physicalSize = size * _devicePixelRatio
    ..devicePixelRatio = _devicePixelRatio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        debugShowCheckedModeBanner: false,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await _precacheImages(tester);

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('$_outputDir/$name.png'),
  );
}

/// Asset-Bilder laden nicht innerhalb der Fake-Async-Uhr des Widget-Tests —
/// ohne diesen Schritt bliebe z. B. das Fahrrad neben dem Login-Wortzeichen
/// leer. Bewusst nur Assets: Datei- und Netzbilder laufen hier in einen
/// Deadlock bzw. ins Leere.
Future<void> _precacheImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final provider = (element.widget as Image).image;
      if (provider is! AssetImage && provider is! ExactAssetImage) continue;
      await precacheImage(provider, element);
    }
  });
  await tester.pumpAndSettle();
}

/// Dieselben Demo-Optionen, die der Bestand beim Scannen mitgibt.
final _demoOptions = [
  DemoScanOption(
    ean: '4029876501233',
    label: 'Katalogartikel simulieren',
    subtitle: 'EAN 4029876501233 · Abus Bordo 6000 Faltschloss 90cm',
    icon: Symbols.qr_code,
  ),
  DemoScanOption(
    ean: '4711234567899',
    label: 'Eigenen Artikel simulieren',
    subtitle: 'EAN 4711234567899 · Eigenes Produkt · KMC Kette X11',
    icon: Symbols.qr_code,
  ),
  DemoScanOption(
    ean: '978020137962',
    label: 'Unbekannten Artikel simulieren',
    subtitle: 'EAN 978020137962 · Unbekanntes Produkt',
    icon: Symbols.question_mark_rounded,
  ),
  DemoScanOption(
    ean: '4029876501234',
    label: 'Ungültigen Barcode simulieren',
    subtitle: 'EAN 4029876501234 · falsche Prüfziffer',
    icon: Symbols.error_rounded,
  ),
];

void main() {
  setUpAll(_loadFonts);

  testWidgets('01 login screen', (tester) async {
    await _capture(tester, '01-login-screen', const LoginScreen());
  });

  testWidgets('02 overview screen', (tester) async {
    await _capture(
      tester,
      '02-overview-screen',
      const OverviewScreen(),
      overrides: [
        articleRepositoryProvider.overrideWithValue(
          _SeedArticleRepository.fromSeed(),
        ),
      ],
    );
  });

  testWidgets('03 overview empty state', (tester) async {
    await _capture(
      tester,
      '03-overview-empty-state',
      const OverviewScreen(),
      overrides: [
        articleRepositoryProvider.overrideWithValue(
          _SeedArticleRepository(const []),
        ),
      ],
    );
  });

  testWidgets('04 overview without search results', (tester) async {
    await _capture(
      tester,
      '04-overview-no-search-results',
      const OverviewScreen(),
      overrides: [
        articleRepositoryProvider.overrideWithValue(
          _SeedArticleRepository.fromSeed(),
        ),
        searchQueryProvider.overrideWith((ref) => 'Klingel'),
        // Sonst stuende die Suche im Screenshot leer da, waehrend darunter
        // das Ergebnis zu ihr steht.
        searchControllerProvider.overrideWith(
          (ref) => TextEditingController(text: 'Klingel'),
        ),
      ],
    );
  });

  testWidgets('05 scanner screen', (tester) async {
    await _capture(
      tester,
      '05-scanner-screen',
      ScannerScreen(
        title: 'Artikel anlegen',
        demoOptions: _demoOptions,
        onEanScanned: (context, ref, ean) async {},
      ),
    );
  });

  testWidgets('06 article form new', (tester) async {
    await _capture(
      tester,
      '06-article-form-new',
      const ArticleFormScreen(),
      size: _tallForm,
      overrides: [
        articleRepositoryProvider.overrideWithValue(
          _SeedArticleRepository.fromSeed(),
        ),
      ],
    );
  });

  testWidgets('07 article form edit', (tester) async {
    final repository = _SeedArticleRepository.fromSeed();
    await _capture(
      tester,
      '07-article-form-edit',
      ArticleFormScreen(article: repository.articles.first),
      size: _tallForm,
      overrides: [articleRepositoryProvider.overrideWithValue(repository)],
    );
  });
}
