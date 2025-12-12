import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/driver_provider.dart';
import '../../services/image_upload_service.dart';

class DriverApplicationScreen extends StatefulWidget {
  const DriverApplicationScreen({super.key});

  @override
  State<DriverApplicationScreen> createState() => _DriverApplicationScreenState();
}

class _DriverApplicationScreenState extends State<DriverApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUploadService = ImageUploadService();
  
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  
  File? _licenseImage;
  File? _vehicleImage;
  bool _isLoading = false;
  
  String? _selectedVehicleType;
  final List<String> _vehicleTypes = ['Car', 'Motorcycle', 'Bicycle', 'Van'];

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickLicenseImage() async {
    try {
      final image = await _imageUploadService.pickImage();
      if (image != null) {
        setState(() {
          _licenseImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickVehicleImage() async {
    try {
      final image = await _imageUploadService.pickImage();
      if (image != null) {
        setState(() {
          _vehicleImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (_licenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your license photo')),
      );
      return;
    }

    if (_vehicleImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your vehicle photo')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await context.read<DriverProvider>().applyAsDriver(
      vehicleType: _selectedVehicleType!,
      vehicleNumber: _vehicleNumberController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim(),
      licenseImage: _licenseImage!,
      vehicleImage: _vehicleImage!,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          title: const Text('Application Submitted!'),
          content: const Text(
            'Your driver application has been submitted successfully. '
            'We will review it and get back to you soon.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                context.go('/');
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      );
    } else {
      final error = context.read<DriverProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to submit application'),
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
        title: const Text('Become a Driver'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            const Text(
              'Driver Application',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join our delivery team and start earning!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // Vehicle Type
            DropdownButtonFormField<String>(
              value: _selectedVehicleType,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type*',
                filled: true,
                fillColor: Colors.white,
              ),
              items: _vehicleTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select vehicle type';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Vehicle Number
            TextFormField(
              controller: _vehicleNumberController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number*',
                hintText: 'e.g., ABC-1234',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter vehicle number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // License Number
            TextFormField(
              controller: _licenseNumberController,
              decoration: const InputDecoration(
                labelText: 'Driver License Number*',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter license number';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // License Photo
            const Text(
              'Driver License Photo*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickLicenseImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _licenseImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _licenseImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _licenseImage = null;
                                });
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to upload license photo',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Vehicle Photo
            const Text(
              'Vehicle Photo*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickVehicleImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _vehicleImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _vehicleImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _vehicleImage = null;
                                });
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to upload vehicle photo',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitApplication,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Application',
                        style: TextStyle(
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
}