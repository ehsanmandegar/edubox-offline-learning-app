import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edubox_app/main.dart';

void main() {
  testWidgets('EduBox app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EduBoxApp());

    // Verify that the app starts without crashing
    expect(find.text('Loading EduBox...'), findsOneWidget);
  });
}