// test/design_system/atoms/app_segment_test.dart
import 'package:bikedrop/design_system/atoms/app_segment.dart';
import 'package:bikedrop/design_system/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

AnimatedContainer _container(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));

Text _text(WidgetTester tester) => tester.widget<Text>(find.text('Bestellt'));

Container _dot(WidgetTester tester) => tester.widget<Container>(
  find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration! as BoxDecoration).shape == BoxShape.circle,
  ),
);

void main() {
  testWidgets('renders the label', (tester) async {
    await tester.pumpWidget(
      _wrap(AppSegment(label: 'Bestellt', selected: false, onTap: () {})),
    );

    expect(find.text('Bestellt'), findsOneWidget);
  });

  testWidgets('fills the background and turns the text white when selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(AppSegment(label: 'Bestellt', selected: true, onTap: null)),
    );

    final decoration = _container(tester).decoration as BoxDecoration;
    expect(decoration.color, AppColors.accent);
    expect(_text(tester).style?.color, AppColors.white);
  });

  testWidgets(
    'is transparent with secondary text color when not selected',
    (tester) async {
      await tester.pumpWidget(
        _wrap(AppSegment(label: 'Bestellt', selected: false, onTap: () {})),
      );

      final decoration = _container(tester).decoration as BoxDecoration;
      expect(decoration.color, Colors.transparent);
      expect(_text(tester).style?.color, AppColors.textSecondary);
    },
  );

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        AppSegment(
          label: 'Bestellt',
          selected: false,
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.tap(find.text('Bestellt'));

    expect(tapped, isTrue);
  });

  testWidgets('renders a colored dot when dotColor is set', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppSegment(
          label: 'Bestellt',
          selected: false,
          dotColor: Colors.orange,
          onTap: () {},
        ),
      ),
    );

    final decoration = _dot(tester).decoration! as BoxDecoration;
    expect(decoration.color, Colors.orange);
  });

  testWidgets('renders no dot when dotColor is not set', (tester) async {
    await tester.pumpWidget(
      _wrap(AppSegment(label: 'Bestellt', selected: false, onTap: () {})),
    );

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle,
      ),
      findsNothing,
    );
  });

  testWidgets('keeps the dot fully colored when selected', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppSegment(
          label: 'Bestellt',
          selected: true,
          dotColor: Colors.orange,
          onTap: null,
        ),
      ),
    );

    final decoration = _dot(tester).decoration! as BoxDecoration;
    expect(decoration.color, Colors.orange);
  });
}
