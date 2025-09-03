import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/category_form_provider.dart';
import 'package:ricashy_app/src/data/local_database/database.dart'; // Added import for Category

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);
    final categoryRepository = ref.read(categoryRepositoryProvider);

    void showCategoryForm({Category? category}) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          final _formKey = GlobalKey<FormState>(); // Added Form Key
          final categoryFormNotifier = ref.read(categoryFormNotifierProvider.notifier);
          // Initialize form with existing category data if editing
          if (category != null) {
            Future.microtask(() => categoryFormNotifier.setCategoryForEdit(category));
          } else {
            Future.microtask(() => categoryFormNotifier.resetForm()); // Reset form for new category
          }
          return AlertDialog(
            title: Text(category == null ? 'New Category' : 'Edit Category'),
            content: Form(
              key: _formKey, // Assign Form Key
              child: TextFormField(
                initialValue: category?.description,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: categoryFormNotifier.setDescription,
                autofocus: true,
                maxLength: 50, // Added maxLength
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description cannot be empty.';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) { // Validate form
                    final success = await ref.read(categoryFormNotifierProvider.notifier).submitCategory();
                    if (!context.mounted) return;
                    Navigator.of(dialogContext).pop();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(category == null ? 'Category added successfully!' : 'Category updated successfully!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save category.')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: categoriesAsyncValue.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories yet. Add one!'),
            );
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showCategoryForm(category: category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final transactionRepository = ref.read(transactionRepositoryProvider);
                        final hasTransactions = await transactionRepository.hasTransactionsForCategory(category.id);

                        String confirmationMessage;
                        if (hasTransactions) {
                          confirmationMessage = 'This category has associated transactions. Deleting it will set those transactions to uncategorized. Are you sure you want to delete "${category.description}"?';
                        } else {
                          confirmationMessage = 'Are you sure you want to delete "${category.description}"?';
                        }

                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Category'),
                            content: Text(confirmationMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await categoryRepository.deleteCategory(category.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Category "${category.description}" deleted.')),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to delete category: ${e.toString()}')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCategoryForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}