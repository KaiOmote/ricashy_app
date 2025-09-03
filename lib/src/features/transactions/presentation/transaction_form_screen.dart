import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/category_form_provider.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/category_provider.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/transaction_form_provider.dart';

class TransactionFormScreen extends ConsumerWidget {
  const TransactionFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(transactionFormNotifierProvider);
    final formNotifier = ref.read(transactionFormNotifierProvider.notifier);
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);

    final descriptionController = TextEditingController(text: formState.description);
    final amountController = TextEditingController(text: formState.amount.toString());

    void presentDatePicker() async {
      final now = DateTime.now();
      final firstDate = DateTime(now.year - 1, now.month, now.day);
      final lastDate = now;

      final pickedDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: firstDate,
        lastDate: lastDate,
      );

      if (pickedDate != null) {
        formNotifier.setDate(pickedDate);
      }
    }

    void submitTransaction() async {
      await formNotifier.submitTransaction();
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }

    void showCategoryForm() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('New Category'),
            content: Consumer(
              builder: (context, ref, child) {
                final categoryFormNotifier = ref.read(categoryFormNotifierProvider.notifier);
                return TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: categoryFormNotifier.setDescription,
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(categoryFormNotifierProvider.notifier).submitCategory();
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
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
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: formNotifier.setDescription,
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) => formNotifier.setAmount(double.tryParse(value) ?? 0.0),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Picked Date: ${formState.date.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  IconButton(
                    onPressed: presentDatePicker,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: categoriesAsyncValue.when(
                      data: (categories) {
                        return DropdownButtonFormField<int>(
                          initialValue: formState.categoryId,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.description),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              formNotifier.setCategory(value);
                            }
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ),
                  IconButton(
                    onPressed: showCategoryForm,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              RadioGroup<bool>(
                groupValue: formState.isExpense,
                onChanged: (value) => formNotifier.setIsExpense(value!),
                child: Row(
                  children: const [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Expense'),
                        value: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Income'),
                        value: false,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitTransaction,
                child: const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
