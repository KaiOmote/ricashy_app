import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/category_form_provider.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/category_provider.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:intl/intl.dart'; // Added import for intl

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final FocusNode _amountFocusNode; // Added FocusNode

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _amountFocusNode = FocusNode(); // Initialize FocusNode

    // Add listener to format amount when focus is lost or gained
    _amountFocusNode.addListener(() {
      if (!_amountFocusNode.hasFocus) {
        // When focus is lost, format the text if it's not empty
        final parsedValue = double.tryParse(_amountController.text.replaceAll('¥', '').replaceAll(',', '')) ?? 0.0;
        if (parsedValue != 0.0) { // Only format if there's a non-zero value
          final formatter = NumberFormat.currency(symbol: '¥', decimalDigits: 0);
          _amountController.value = _amountController.value.copyWith(
            text: formatter.format(parsedValue),
            selection: TextSelection.collapsed(offset: formatter.format(parsedValue).length),
          );
        } else {
          // If value is 0.0, clear the field
          _amountController.text = '';
        }
      } else {
        // When focus is gained, remove currency symbol for easier editing
        _amountController.text = _amountController.text.replaceAll('¥', '').replaceAll(',', '');
        // Place cursor at the end
        _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormNotifierProvider);
    final formNotifier = ref.read(transactionFormNotifierProvider.notifier);
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);

    // Only update description controller if text has changed and preserve selection
    if (_descriptionController.text != formState.description) {
      _descriptionController.value = _descriptionController.value.copyWith(
        text: formState.description,
        selection: TextSelection.collapsed(offset: formState.description.length),
      );
    }

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
      if (_formKey.currentState!.validate()) {
        await formNotifier.submitTransaction();
        if (!context.mounted) return;
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please correct the errors in the form')),
        );
      }
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: formNotifier.setDescription,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  focusNode: _amountFocusNode, // Attach FocusNode
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Remove commas and currency symbol before parsing
                    final cleanValue = value.replaceAll(',', '').replaceAll('¥', '');
                    formNotifier.setAmount(double.tryParse(cleanValue) ?? 0.0);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    // Remove commas and currency symbol before parsing
                    final cleanValue = value.replaceAll(',', '').replaceAll('¥', '');
                    if (cleanValue.isEmpty) { // Check if empty after removing symbol
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(cleanValue) == null || double.tryParse(cleanValue)! <= 0) {
                      return 'Please enter a valid positive amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Picked Date: ${formState.date.toLocal().toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: presentDatePicker,
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: categoriesAsyncValue.when(
                        data: (categories) {
                          return DropdownButtonFormField<int>(
                            initialValue: formState.categoryId,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
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
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Text('Error: $error'),
                      ),
                    ),
                    IconButton(
                      onPressed: showCategoryForm,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: submitTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}