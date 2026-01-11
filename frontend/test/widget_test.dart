// basic widget test scaffold for flutter testing

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_manager/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // build the app and render a frame
    await tester.pumpWidget(const MainApp());

    // verify counter starts at zero
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // tap the add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // verify counter incremented
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
