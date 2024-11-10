import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_calculator/main.dart';

void main() {
  group('Calculator Widget Tests', () {
    testWidgets('Calculator displays numbers when pressed', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const CalculatorApp());

      // Verify that our calculator starts with 0
      expect(find.text('0'), findsOneWidget);

      // Tap number 5 and verify it appears
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Calculator performs addition correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Input first number (5)
      await tester.tap(find.text('5'));
      await tester.pump();

      // Tap the plus button
      await tester.tap(find.text('+'));
      await tester.pump();

      // Input second number (3)
      await tester.tap(find.text('3'));
      await tester.pump();

      // Tap equals
      await tester.tap(find.text('='));
      await tester.pump();

      // Verify the result (8)
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('Calculator clear button works', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Input a number
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(find.text('5'), findsOneWidget);

      // Press clear button
      await tester.tap(find.text('C'));
      await tester.pump();

      // Verify display returns to 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Calculator handles decimal points', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Input a decimal number (2.5)
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('.'));
      await tester.pump();
      await tester.tap(find.text('5'));
      await tester.pump();

      // Verify the decimal number appears
      expect(find.text('2.5'), findsOneWidget);
    });

    testWidgets('Calculator handles negative numbers', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Input a number
      await tester.tap(find.text('5'));
      await tester.pump();

      // Make it negative
      await tester.tap(find.text('±'));
      await tester.pump();

      // Verify the number is negative
      expect(find.text('-5'), findsOneWidget);
    });

    testWidgets('Calculator performs multiplication correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // Input first number (4)
      await tester.tap(find.text('4'));
      await tester.pump();

      // Tap the multiplication button
      await tester.tap(find.text('×'));
      await tester.pump();

      // Input second number (3)
      await tester.tap(find.text('3'));
      await tester.pump();

      // Tap equals
      await tester.tap(find.text('='));
      await tester.pump();

      // Verify the result (12)
      expect(find.text('12'), findsOneWidget);
    });
  });
}