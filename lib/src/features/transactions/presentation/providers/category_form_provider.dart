import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';
import 'package:drift/drift.dart' as drift;

class CategoryFormState {
  final int? id;
  final String description;

  CategoryFormState({
    this.id,
    this.description = '',
  });

  CategoryFormState copyWith({
    int? id,
    String? description,
  }) {
    return CategoryFormState(
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }
}

class CategoryFormNotifier extends StateNotifier<CategoryFormState> {
  CategoryFormNotifier(this.ref) : super(CategoryFormState());

  final Ref ref;

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setCategoryForEdit(Category category) {
    state = CategoryFormState(id: category.id, description: category.description);
  }

  Future<void> submitCategory() async {
    final categoryRepository = ref.read(categoryRepositoryProvider);

    if (state.id == null) {
      // Insert new category
      await categoryRepository.insertCategory(CategoriesCompanion(
        description: drift.Value(state.description),
      ));
    } else {
      // Update existing category
      await categoryRepository.updateCategory(CategoriesCompanion(
        id: drift.Value(state.id!),
        description: drift.Value(state.description),
      ));
    }
  }
}

final categoryFormNotifierProvider = StateNotifierProvider<CategoryFormNotifier, CategoryFormState>((ref) {
  return CategoryFormNotifier(ref);
});