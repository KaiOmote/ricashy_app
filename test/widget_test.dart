import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricashy_app/main.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';
import 'package:drift/native.dart';

void main() {
  group('App Widget Tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(executor: NativeDatabase.memory());
    });

    tearDown(() {
      database.close();
    });

    testWidgets('App starts and displays the dashboard screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MyApp(),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('Navigate to Transactions screen', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(database),
            ],
            child: const MyApp(),
          ),
        );

        await tester.tap(find.byIcon(Icons.list));
        await tester.pump();

        expect(find.text('Transactions'), findsAtLeastNWidgets(1));
      });
    });
  });
}