import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/items_provider.dart';
import '../../models/size_enum.dart';
import '../../models/condition_enum.dart';
import '../../models/gender_enum.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  Size? _selectedSize;
  Condition? _selectedCondition;
  Gender? _selectedGender;
  double? _minPrice;
  double? _maxPrice;
  bool? _isDonation;

  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<ItemsProvider>();
    _selectedSize = provider.selectedSize != null
        ? Size.fromString(provider.selectedSize!)
        : null;
    _selectedCondition = provider.selectedCondition != null
        ? Condition.fromString(provider.selectedCondition!)
        : null;
    _selectedGender = provider.selectedGender != null
        ? Gender.fromString(provider.selectedGender!)
        : null;
    _minPrice = provider.minPrice;
    _maxPrice = provider.maxPrice;
    _isDonation = provider.isDonation;

    _minPriceController.text = _minPrice?.toString() ?? '';
    _maxPriceController.text = _maxPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final provider = context.read<ItemsProvider>();
    
    provider.setSize(_selectedSize?.value);
    provider.setCondition(_selectedCondition?.value);
    provider.setGender(_selectedGender?.value);
    provider.setPriceRange(_minPrice, _maxPrice);
    provider.setDonation(_isDonation);
    
    provider.loadItems(refresh: true);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedSize = null;
      _selectedCondition = null;
      _selectedGender = null;
      _minPrice = null;
      _maxPrice = null;
      _isDonation = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });

    final provider = context.read<ItemsProvider>();
    provider.setSize(null);
    provider.setCondition(null);
    provider.setGender(null);
    provider.setPriceRange(null, null);
    provider.setDonation(null);
    provider.loadItems(refresh: true);
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Size Filter
          const Text('Size', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Size.all.map((size) {
              return ChoiceChip(
                label: Text(size.displayName),
                selected: _selectedSize == size,
                onSelected: (selected) {
                  setState(() => _selectedSize = selected ? size : null);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Condition Filter
          const Text('Condition', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Condition.all.map((condition) {
              return ChoiceChip(
                label: Text(condition.displayName),
                selected: _selectedCondition == condition,
                onSelected: (selected) {
                  setState(() => _selectedCondition = selected ? condition : null);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Gender Filter
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Gender.all.map((gender) {
              return ChoiceChip(
                label: Text(gender.displayName),
                selected: _selectedGender == gender,
                onSelected: (selected) {
                  setState(() => _selectedGender = selected ? gender : null);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Price Range
          const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _minPrice = double.tryParse(v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _maxPrice = double.tryParse(v),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Donation Filter
          SwitchListTile(
            title: const Text('Show only donations'),
            value: _isDonation ?? false,
            onChanged: (v) => setState(() => _isDonation = v ? true : null),
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}