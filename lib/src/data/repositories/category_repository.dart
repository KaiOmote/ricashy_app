import 'package:ricashy_app/src/data/local_database/database.dart';

class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository(this._db);

  Future<int> insertCategory(CategoriesCompanion entry) {
    return _db.into(_db.categories).insert(entry);
  }

  Future<bool> updateCategory(CategoriesCompanion entry) {
    return _db.update(_db.categories).replace(entry);
  }

  Future<int> deleteCategory(int id) {
    return (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }

  Stream<List<Category>> getAllCategories() {
    return _db.select(_db.categories).watch();
  }

  Future<bool> categoryExists(String description, {int? excludeId}) async {
    var query = _db.select(_db.categories)
      ..where((c) => c.description.equals(description));

    if (excludeId != null) {
      query.where((c) => c.id.isNotValue(excludeId));
    }

    final count = await query.get().then((list) => list.length);
    return count > 0;
  }
}