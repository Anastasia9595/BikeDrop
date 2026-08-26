/// Prueft einen gescannten Barcode und liefert ihn in kanonischer Form
/// zurueck — oder null, wenn er keine gueltige EAN/UPC ist.
///
/// Akzeptiert EAN-13, EAN-8 und UPC-A. Ein UPC-A wird mit fuehrender Null
/// zur EAN-13; seine Pruefziffer bleibt dabei unveraendert gueltig, sodass
/// Lookup und Formular durchgaengig mit 13 Stellen arbeiten.
String? normalizeScannedEan(String raw) {
  final digits = raw.trim();
  if (digits.length != 8 && digits.length != 12 && digits.length != 13) {
    return null;
  }
  if (!_isAllDigits(digits)) return null;
  if (!_hasValidCheckDigit(digits)) return null;

  return digits.length == 12 ? '0$digits' : digits;
}

bool _isAllDigits(String value) {
  for (var i = 0; i < value.length; i++) {
    final code = value.codeUnitAt(i);
    if (code < 0x30 || code > 0x39) return false;
  }
  return true;
}

/// Modulo-10-Pruefung nach GS1.
///
/// Gerechnet wird von rechts mit abwechselnden Gewichten 3 und 1 — dadurch
/// gilt dieselbe Formel fuer EAN-8, UPC-A und EAN-13, statt drei Sonderfaelle
/// nach Laenge zu unterscheiden.
bool _hasValidCheckDigit(String digits) {
  final lastIndex = digits.length - 1;
  var sum = 0;
  for (var i = lastIndex - 1; i >= 0; i--) {
    final digit = digits.codeUnitAt(i) - 0x30;
    sum += digit * ((lastIndex - 1 - i).isEven ? 3 : 1);
  }
  final expected = (10 - sum % 10) % 10;

  return expected == digits.codeUnitAt(lastIndex) - 0x30;
}
