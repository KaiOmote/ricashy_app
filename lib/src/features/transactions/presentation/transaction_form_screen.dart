import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/category_form_provider.dart';
// import 'package:ricashy_app/src/features/transactions/presentation/providers/category_provider.dart'; // Removed
import 'package:ricashy_app/src/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:intl/intl.dart'; // Added import for intl
import 'package:flutter/services.dart'; // Added import for services
import 'package:ricashy_app/src/domain/providers/database_provider.dart'; // Ensure this is present for categoriesStreamProvider

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
        final parsedValue = _parseAmount(_amountController.text);
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
  
  double _parseAmount(String value) {
    final cleanValue = value.replaceAll(',', '').replaceAll('¥', '');
    return double.tryParse(cleanValue) ?? 0.0;
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
        // Check for uncategorized transaction
        if (formState.categoryId == null) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Uncategorized Transaction'),
              content: const Text('You have not selected a category for this transaction. Do you want to proceed?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Proceed'),
                ),
              ],
            ),
          );

          if (confirmed != true) {
            return; // User cancelled, do not submit
          }
        }

        final success = await formNotifier.submitTransaction();
        if (!context.mounted) return;
        if (success) {
          formNotifier.resetForm(); // Call resetForm() after successful submission
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction saved successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save transaction.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please correct the errors in the form')),
        );
      }
    }

    void showCategoryForm() {
      showDialog(
        context: context,
        builder: (dialogContext) {
          final categoryFormNotifier = ref.read(categoryFormNotifierProvider.notifier);
          return AlertDialog(
            title: const Text('New Category'),
            content: TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: categoryFormNotifier.setDescription,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await ref.read(categoryFormNotifierProvider.notifier).submitCategory();
                  if (!context.mounted) return;
                  Navigator.of(dialogContext).pop();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category added successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add category.')),
                    );
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
                  maxLength: 100, // Added maxLength
                  maxLengthEnforcement: MaxLengthEnforcement.enforced, // Added maxLengthEnforcement
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
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    formNotifier.setAmount(_parseAmount(value));
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final cleanValue = _parseAmount(value).toString();
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
                categoriesAsyncValue.when(
                  data: (categories) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: formState.categoryId,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: categories.map((category) {
                              return DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.description),
                              );
                            }).toList(),
                            onChanged: (value) {
                              formNotifier.setCategoryId(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: showCategoryForm,
                          tooltip: 'Add New Category',
                          padding: const EdgeInsets.only(top: 8),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Could not load categories: $err'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Expense'),
                        value: true,
                        groupValue: formState.isExpense,
                        onChanged: (value) {
                          if (value != null) formNotifier.setIsExpense(value);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Income'),
                        value: false,
                        groupValue: formState.isExpense,
                        onChanged: (value) {
                          if (value != null) formNotifier.setIsExpense(value);
                        },
                      ),
                    ),
                  ],
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