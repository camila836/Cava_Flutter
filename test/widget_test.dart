import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cava_app/core/cava_theme.dart';

void main() {
  test('CAVA theme can be created', () {
    expect(cavaTheme(), isA<ThemeData>());
  });
}
