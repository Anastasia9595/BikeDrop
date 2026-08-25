import 'dart:convert';

import 'package:flutter/services.dart';

import '../interface/catalog_interface.dart';
import '../models/catalogarticle.dart';

/// Katalog aus dem gebundelten Seed-JSON. Der Katalog ist reine Stammdaten
/// und wird nur gelesen — er wird beim ersten Zugriff geladen und danach
/// im Speicher gehalten.
class MockCatalogRepository implements CatalogRepository {
  Map<String, CatalogArticle>? _catalogByEan;

  Future<Map<String, CatalogArticle>> _ensureLoaded() async {
    final cached = _catalogByEan;
    if (cached != null) return cached;

    final jsonString = await rootBundle.loadString(
      'assets/data/catalog_seed.json',
    );
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final catalog = {
      for (final entry in jsonList)
        (entry as Map<String, dynamic>)['ean'] as String:
            CatalogArticle.fromJson(entry),
    };
    _catalogByEan = catalog;
    return catalog;
  }

  @override
  Future<CatalogArticle?> lookupByEan(String ean) async {
    final catalog = await _ensureLoaded();
    return catalog[ean];
  }
}
