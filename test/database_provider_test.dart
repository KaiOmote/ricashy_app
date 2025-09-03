import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:drift/native.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';

void main() {
  group('Database and Repository Providers', () {
    late ProviderContainer container;
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(executor: NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      database.close();
    });

    test('databaseProvider provides an AppDatabase instance', () {
      final db = container.read(databaseProvider);
      expect(db, isA<AppDatabase>());
    });

    test('transactionRepositoryProvider provides a repository instance', () {
      final repository = container.read(transactionRepositoryProvider);
      expect(repository, isNotNull);
    });

    test('transactionsStreamProvider can be read', () async {
      final stream = container.read(transactionsStreamProvider);
      expect(stream, isA<AsyncValue<List<Transaction>>>());
    });
  });
}