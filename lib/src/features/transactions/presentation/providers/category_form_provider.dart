import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';
import 'package:drift/drift.dart' as drift;

class CategoryFormNotifier extends StateNotifier<String> {
  CategoryFormNotifier(this.ref) : super('');

  final Ref ref;

  void setDescription(String description) {
    state = description;
  }

  Future<void> submitCategory() async {
    final db = ref.read(databaseProvider);
    await db.into(db.categories).insert(CategoriesCompanion(
          description: drift.Value(state),
        ));
  }
}

final categoryFormNotifierProvider = StateNotifierProvider<CategoryFormNotifier, String>((ref) {
  return CategoryFormNotifier(ref);
});
