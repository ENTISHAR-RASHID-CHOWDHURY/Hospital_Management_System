import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/core/widgets/standard_cards.dart';
import 'package:flutter/material.dart';

void main() {
  group('StandardCard Widget Tests', () {
    testWidgets('StandardCard displays content correctly',
        (WidgetTester tester) async {
      const testContent = Text('Test Content');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StandardCard(
              child: testContent,
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(StandardCard), findsOneWidget);
    });

    testWidgets('StandardCard handles tap events', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StandardCard(
              onTap: () => tapped = true,
              child: const Text('Tappable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(StandardCard));
      expect(tapped, isTrue);
    });

    testWidgets('StatCard displays statistics correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Test Stat',
              value: '123',
              icon: Icons.star,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Test Stat'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('ActionCard triggers actions correctly',
        (WidgetTester tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionCard(
              title: 'Test Action',
              description: 'Test Description',
              icon: Icons.add,
              color: Colors.blue,
              onPressed: () => actionTriggered = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ActionCard));
      expect(actionTriggered, isTrue);
      expect(find.text('Test Action'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('ProgressCard shows progress correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              title: 'Progress Test',
              progress: 0.75,
              subtitle: '75 of 100 completed',
              color: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('Progress Test'), findsOneWidget);
      expect(find.text('75 / 100'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('Card Styling Tests', () {
    testWidgets('StandardCard applies correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StandardCard(
              type: CardType.elevated,
              child: Text('Styled Card'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 8.0);
    });

    testWidgets('StandardCard applies custom margin',
        (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(20);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StandardCard(
              margin: customMargin,
              child: Text('Margin Test'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.margin, customMargin);
    });
  });
}
