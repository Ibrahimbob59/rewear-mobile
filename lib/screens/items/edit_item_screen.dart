import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/items_provider.dart';
import '../../models/item_model.dart';
import '../../models/condition_enum.dart';

class EditItemScreen extends StatefulWidget {
  final String itemId;

  const EditItemScreen({super.key, required this.itemId});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  
  Condition? _selectedCondition;
  bool _isLoading = false;
  Item? _item;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() {
    final provider = context.read<ItemsProvider>();
    _item = provider.items.firstWhere((i) => i.id.toString() == widget.itemId);
    
    _titleController = TextEditingController(text: _item!.title);
    _descriptionController = TextEditingController(text: _item!.description);
    _priceController = TextEditingController(
      text: _item!.price?.toString() ?? '',
    );
    _selectedCondition = _item!.condition;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<ItemsProvider>().updateItem(
      id: int.parse(widget.itemId),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      condition: _selectedCondition!.value,
      price: _item!.isDonation ? null : double.tryParse(_priceController.text),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully!')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<ItemsProvider>().error ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can only edit title, description, price, and condition',
                      style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title*',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description*',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),

            const SizedBox(height: 16),

            // Condition
            DropdownButtonFormField<Condition>(
              value: _selectedCondition,
              decoration: const InputDecoration(
                labelText: 'Condition*',
                border: OutlineInputBorder(),
              ),
              items: Condition.all.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.displayName),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedCondition = v),
              validator: (v) => v == null ? 'Required' : null,
            ),

            const SizedBox(height: 16),

            // Price (if not donation)
            if (!_item!.isDonation)
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price*',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (_item!.isDonation) return null;
                  if (v?.trim().isEmpty ?? true) return 'Required';
                  if (double.tryParse(v!) == null) return 'Invalid price';
                  return null;
                },
              ),

            const SizedBox(height: 32),

            // Update Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateItem,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}