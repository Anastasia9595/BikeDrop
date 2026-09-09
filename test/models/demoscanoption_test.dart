// test/models/demoscanoption_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/models/demoscanoption.dart';

void main() {
  test('has no color by default', () {
    const option = DemoScanOption(
      label: 'Katalogartikel',
      subtitle: 'EAN 4029876501233',
      ean: '4029876501233',
      icon: Icons.qr_code,
    );

    expect(option.color, isNull);
  });

  test('keeps an explicitly set color', () {
    const option = DemoScanOption(
      label: 'Katalogartikel',
      subtitle: 'EAN 4029876501233',
      ean: '4029876501233',
      icon: Icons.qr_code,
      color: Colors.blue,
    );

    expect(option.color, Colors.blue);
  });
}
