import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';
import 'package:drift/drift.dart' as drift;

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  bool _isExpense = true;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final transactionRepository = ref.read(transactionRepositoryProvider);

      final newTransaction = TransactionsCompanion(
        description: drift.Value(_descriptionController.text),
        amount: drift.Value(double.parse(_amountController.text) * (_isExpense ? -1 : 1)),
        date: drift.Value(_selectedDate ?? DateTime.now()),
        // categoryId: drift.Value(_selectedCategory), // TODO: Handle category ID
      );

      await transactionRepository.insertTransaction(newTransaction);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date chosen!'
                          : 'Picked Date: ${(_selectedDate!).toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  IconButton(
                    onPressed: _presentDatePicker,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  // TODO: Populate with actual categories from database
                  DropdownMenuItem(value: 'Food', child: Text('Food')),
                  DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category.';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Expense'),
                      value: true,
                      groupValue: _isExpense,
                      onChanged: (value) {
                        setState(() {
                          _isExpense = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Income'),
                      value: false,
                      groupValue: _isExpense,
                      onChanged: (value) {
                        setState(() {
                          _isExpense = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTransaction,
                child: const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}