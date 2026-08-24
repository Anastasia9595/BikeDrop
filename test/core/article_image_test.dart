// test/core/article_image_test.dart
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bikedrop/core/article_image.dart';

void main() {
  test('returns null without a source', () {
    expect(articleImageProvider(null), isNull);
    expect(articleImageProvider(''), isNull);
  });

  test('loads http(s) sources over the network', () {
    expect(
      articleImageProvider('https://example.com/bike.png'),
      isA<NetworkImage>(),
    );
    expect(
      articleImageProvider('http://example.com/bike.png'),
      isA<NetworkImage>(),
    );
  });

  test('treats everything else as a local file path', () {
    final provider = articleImageProvider('/tmp/bike.jpg');

    expect(provider, isA<FileImage>());
    expect((provider! as FileImage).file, isA<File>());
    expect((provider as FileImage).file.path, '/tmp/bike.jpg');
  });
}
