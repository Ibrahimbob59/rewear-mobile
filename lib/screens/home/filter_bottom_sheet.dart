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
  String? _selectedSize;
  String? _selectedCondition;
  String? _selectedGender;
  double? _minPrice;
  double? _maxPrice;
  bool? _isDonation;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ItemsProvider>();
    _selectedSize = provider.selectedSize;
    _selectedCondition = provider.selectedCondition;
    _selectedGender = provider.selectedGender;
    _minPrice = provider.minPrice;
    _maxPrice = provider.maxPrice;
    _isDonation = provider.isDonation;
  }

  void _applyFilters() {
    final provider = context.read<ItemsProvider>();
    provider.setSize(_selectedSize);
    provider.setCondition(_selectedCondition);
    provider.setGender(_selectedGender);
    provider.setPriceRange(_minPrice, _maxPrice);
    provider.setDonation(_isDonation);
    provider.applyFilters();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Filters
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Size
                    const Text(
                      'Size',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Size.all.map((size) {
                        final isSelected = _selectedSize == size.value;
                        return ChoiceChip(
                          label: Text(size.value),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSize = selected ? size.value : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Condition
                    const Text(
                      'Condition',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Condition.all.map((condition) {
                        final isSelected = _selectedCondition == condition.value;
                        return ChoiceChip(
                          label: Text(condition.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCondition = selected ? condition.value : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Gender
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: Gender.all.map((gender) {
                        final isSelected = _selectedGender == gender.value;
                        return ChoiceChip(
                          label: Text(gender.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedGender = selected ? gender.value : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Price Range
                    const Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Min',
                              prefixText: '\$',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _minPrice = double.tryParse(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Max',
                              prefixText: '\$',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _maxPrice = double.tryParse(value);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Donation
                    CheckboxListTile(
                      title: const Text('Show donations only'),
                      value: _isDonation ?? false,
                      onChanged: (value) {
                        setState(() {
                          _isDonation = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}