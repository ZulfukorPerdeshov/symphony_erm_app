import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:symphony_erm_app/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CloudShopMgrApp());

    // Verify that the app launches and shows login screen
    expect(find.text('CloudShopMgr'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });
}