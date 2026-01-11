import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/items_provider.dart';
import '../../models/category_enum.dart';
import '../../models/size_enum.dart';
import '../../models/condition_enum.dart';
import '../../models/gender_enum.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/common/custom_button.dart';
import 'dart:io';

class CharityDonateScreen extends StatefulWidget {
  const CharityDonateScreen({super.key});

  @override
  State<CharityDonateScreen> createState() => _CharityDonateScreenState();
}

class _CharityDonateScreenState extends State<CharityDonateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  
  Category? _selectedCategory;
  Size? _selectedSize;
  Condition? _selectedCondition;
  Gender? _selectedGender;
  
  final List<File> _images = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final imageUploadService = ImageUploadService();
    final pickedImages = await imageUploadService.pickMultipleImages(maxImages: 6 - _images.length);
    
    if (pickedImages.isNotEmpty) {
      setState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final itemsProvider = context.read<ItemsProvider>();
    final success = await itemsProvider.createItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!.value,
      size: _selectedSize!.value,
      condition: _selectedCondition!.value,
      isDonation: true, // This is a donation
      images: _images,
      gender: _selectedGender?.value,
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      price: null, // Free donation
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation listed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/charity/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(itemsProvider.error ?? 'Failed to create donation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Donation'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.volunteer_activism, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'List items you want to donate to charities',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Images
            const Text(
              'Photos (1-6 required)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _images.length + (_images.length < 6 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: Colors.grey[400]),
                          const SizedBox(height: 4),
                          Text('Add', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Primary',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Vintage Denim Jacket',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe the item...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: Category.all.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a category';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Size
            DropdownButtonFormField<Size>(
              value: _selectedSize,
              decoration: const InputDecoration(
                labelText: 'Size *',
                border: OutlineInputBorder(),
              ),
              items: Size.all.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text(size.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSize = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a size';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Condition
            DropdownButtonFormField<Condition>(
              value: _selectedCondition,
              decoration: const InputDecoration(
                labelText: 'Condition *',
                border: OutlineInputBorder(),
              ),
              items: Condition.all.map((cond) {
                return DropdownMenuItem(
                  value: cond,
                  child: Text(cond.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCondition = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a condition';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender
            DropdownButtonFormField<Gender>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: Gender.all.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
            ),
            const SizedBox(height: 16),

            // Brand
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand (Optional)',
                hintText: 'e.g., Nike, Zara',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              onPressed: _submitDonation,
              text: 'Create Donation',
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}