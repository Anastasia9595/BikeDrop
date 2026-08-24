import 'dart:io';

import 'package:flutter/widgets.dart';

/// Baut den passenden [ImageProvider] fuer einen gespeicherten Bildverweis.
///
/// http(s)-Verweise kommen vom Server, alles andere ist ein lokaler
/// Dateipfad — etwa ein gerade aufgenommenes Foto, das noch nicht
/// hochgeladen wurde. Null, wenn kein Bild hinterlegt ist.
ImageProvider? articleImageProvider(String? source) {
  if (source == null || source.isEmpty) return null;
  if (source.startsWith('http://') || source.startsWith('https://')) {
    return NetworkImage(source);
  }
  return FileImage(File(source));
}
