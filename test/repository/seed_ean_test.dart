import 'dart:convert';

import 'package:barcode/barcode.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<Map<String, dynamic>>> _load(String asset) async {
  final jsonString = await rootBundle.loadString(asset);
  return (jsonDecode(jsonString) as List<dynamic>).cast<Map<String, dynamic>>();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final asset in const [
    'assets/data/catalog_seed.json',
    'assets/data/seed_articles.json',
  ]) {
    test('alle EANs in $asset sind gueltige EAN-13', () async {
      final entries = await _load(asset);
      final eans = entries
          .map((e) => e['ean'])
          .whereType<String>()
          .toList();

      expect(eans, isNotEmpty, reason: '$asset enthaelt keine EANs');

      for (final ean in eans) {
        expect(
          () => Barcode.ean13().toSvg(ean),
          returnsNormally,
          reason: '$ean ist keine gueltige EAN-13',
        );
      }
    });
  }

  test('gemeinsame EANs stehen in beiden Seed-Dateien fuer denselben Artikel',
      () async {
    final catalog = await _load('assets/data/catalog_seed.json');
    final articles = await _load('assets/data/seed_articles.json');

    final articleNameByEan = {
      for (final a in articles)
        if (a['ean'] is String) a['ean'] as String: a['name'] as String,
    };

    final shared = catalog
        .where((c) => articleNameByEan.containsKey(c['ean']))
        .toList();

    expect(shared, isNotEmpty, reason: 'keine gemeinsamen EANs gefunden');

    for (final c in shared) {
      expect(c['name'], articleNameByEan[c['ean']], reason: 'EAN ${c['ean']}');
    }
  });
}
