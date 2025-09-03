import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart' as db_provider;

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return ''; // Return an empty string or a temporary path for testing
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  PathProviderPlatform.instance = MockPathProviderPlatform();

  group('Database Provider', () {
    test('databaseProvider provides an AppDatabase instance', () {
      final container = ProviderContainer(
        overrides: [
          db_provider.databaseProvider.overrideWithValue(
            AppDatabase(executor: NativeDatabase.memory()),
          ),
        ],
      );
      final database = container.read(db_provider.databaseProvider);

      expect(database, isA<AppDatabase>());
      container.dispose();
    });

    test('databaseProvider allows database interaction', () async {
      final container = ProviderContainer(
        overrides: [
          db_provider.databaseProvider.overrideWithValue(
            AppDatabase(executor: NativeDatabase.memory()),
          ),
        ],
      );
      final database = container.read(db_provider.databaseProvider);

      // Insert a category
      final categoryId = await database.into(database.categories).insert(
            CategoriesCompanion.insert(description: 'Test Category'),
          );

      expect(categoryId, greaterThan(0));

      // Query the category to verify
      final category = await database.select(database.categories).getSingle();
      expect(category.description, 'Test Category');

      container.dispose();
    });
  });
}