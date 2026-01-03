import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/items_provider.dart';
import '../../services/image_upload_service.dart';
import '../../models/category_enum.dart';
import '../../models/size_enum.dart';
import '../../models/condition_enum.dart';
import '../../models/gender_enum.dart';

class CreateItemScreen extends StatefulWidget {
  const CreateItemScreen({super.key});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUploadService = ImageUploadService();
  
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();

  // Form values
  final List<File> _images = [];
  Category? _selectedCategory;
  Size? _selectedSize;
  Condition? _selectedCondition;
  Gender? _selectedGender;
  bool _isDonation = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final newImages = await _imageUploadService.pickMultipleImages(
        maxImages: 6 - _images.length,
      );

      if (newImages.isNotEmpty) {
        setState(() {
          _images.addAll(newImages);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await _imageUploadService.takePhoto();
      if (photo != null) {
        setState(() {
          _images.add(photo);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to take photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _createListing() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate images
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 1 image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate image sizes
    for (var image in _images) {
      if (!_imageUploadService.validateImageSize(image)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('One or more images exceed 5MB limit'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validate required fields
    if (_selectedCategory == null ||
        _selectedSize == null ||
        _selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate price for non-donations
    if (!_isDonation && _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a price or mark as donation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await context.read<ItemsProvider>().createItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!.value,
      size: _selectedSize!.value,
      condition: _selectedCondition!.value,
      gender: _selectedGender?.value,
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      price: _isDonation
          ? null
          : double.tryParse(_priceController.text.trim()),
      isDonation: _isDonation,
      images: _images,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item listed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/my-listings');
    } else {
      final error = context.read<ItemsProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to create listing'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Listing'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Images Section
            const Text(
              'Photos (1-6 required)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Image Grid
            _buildImageGrid(),

            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title*',
                hintText: 'e.g., Vintage Denim Jacket',
                filled: true,
                fillColor: Colors.white,
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
                labelText: 'Description*',
                hintText: 'Describe your item...',
                filled: true,
                fillColor: Colors.white,
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
                labelText: 'Category*',
                filled: true,
                fillColor: Colors.white,
              ),
              items: Category.all.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Size
            DropdownButtonFormField<Size>(
              value: _selectedSize,
              decoration: const InputDecoration(
                labelText: 'Size*',
                filled: true,
                fillColor: Colors.white,
              ),
              items: Size.all.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text(size.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSize = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a size';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Condition
            DropdownButtonFormField<Condition>(
              value: _selectedCondition,
              decoration: const InputDecoration(
                labelText: 'Condition*',
                filled: true,
                fillColor: Colors.white,
              ),
              items: Condition.all.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(condition.displayName),
                      Text(
                        condition.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select condition';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Gender (Optional)
            DropdownButtonFormField<Gender>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender (Optional)',
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Select gender'),
                ),
                ...Gender.all.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender.displayName),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Brand (Optional)
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand (Optional)',
                hintText: 'e.g., Nike, Zara, H&M',
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Color (Optional)
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color (Optional)',
                hintText: 'e.g., Blue, Red, Black',
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Donation Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Donate this item'),
                subtitle: const Text(
                  'Item will be listed as free for charity',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isDonation,
                onChanged: (value) {
                  setState(() {
                    _isDonation = value;
                    if (value) {
                      _priceController.clear();
                    }
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Price (if not donation)
            if (!_isDonation)
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price*',
                  prefixText: '\$ ',
                  hintText: '0.00',
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_isDonation) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                  }
                  return null;
                },
              ),

            const SizedBox(height: 32),

            // Create Listing Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createListing,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isDonation ? 'List as Donation' : 'Create Listing',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _images.length + (_images.length < 6 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _images.length) {
            // Add Image Button
            return _buildAddImageButton();
          }

          // Image Preview
          return _buildImagePreview(_images[index], index);
        },
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, 
              size: 32, 
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File image, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        
        // Primary Badge
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Remove Button
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
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}