import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../widgets/common/custom_button.dart';

class DriverApplicationScreen extends StatefulWidget {
  const DriverApplicationScreen({super.key});

  @override
  State<DriverApplicationScreen> createState() => _DriverApplicationScreenState();
}

class _DriverApplicationScreenState extends State<DriverApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehiclePlateController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  
  String _vehicleType = 'car';
  DateTime? _licenseExpiryDate;
  
  File? _idCardFront;
  File? _idCardBack;
  File? _driverLicense;
  File? _vehicleRegistration;
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _vehiclePlateController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        switch (type) {
          case 'id_front':
            _idCardFront = File(image.path);
            break;
          case 'id_back':
            _idCardBack = File(image.path);
            break;
          case 'license':
            _driverLicense = File(image.path);
            break;
          case 'vehicle':
            _vehicleRegistration = File(image.path);
            break;
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        _licenseExpiryDate = picked;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idCardFront == null || _idCardBack == null || 
        _driverLicense == null || _vehicleRegistration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_licenseExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select license expiry date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Implement actual API call when backend is ready
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application submitted! Admin will review within 48 hours.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
    context.go('/login');
  }

  Widget _buildImagePicker(String label, String type, File? image) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(type),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: image != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 16,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                switch (type) {
                                  case 'id_front':
                                    _idCardFront = null;
                                    break;
                                  case 'id_back':
                                    _idCardBack = null;
                                    break;
                                  case 'license':
                                    _driverLicense = null;
                                    break;
                                  case 'vehicle':
                                    _vehicleRegistration = null;
                                    break;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply as Driver'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Admin will review your application within 48 hours.',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Vehicle Type *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _vehicleType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'car', child: Text('Car')),
                  DropdownMenuItem(value: 'motorcycle', child: Text('Motorcycle')),
                  DropdownMenuItem(value: 'bike', child: Text('Bike')),
                ],
                onChanged: (value) {
                  setState(() => _vehicleType = value!);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _vehiclePlateController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Plate Number *',
                  hintText: 'e.g., ABC123',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle plate number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _licenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'Driver License Number *',
                  hintText: 'e.g., DL123456',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driver license number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'License Expiry Date *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _licenseExpiryDate != null
                            ? '${_licenseExpiryDate!.day}/${_licenseExpiryDate!.month}/${_licenseExpiryDate!.year}'
                            : 'Select date',
                        style: TextStyle(
                          color: _licenseExpiryDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Required Documents *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Please upload clear, readable photos',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              _buildImagePicker('ID Card (Front)', 'id_front', _idCardFront),
              const SizedBox(height: 16),

              _buildImagePicker('ID Card (Back)', 'id_back', _idCardBack),
              const SizedBox(height: 16),

              _buildImagePicker('Driver License', 'license', _driverLicense),
              const SizedBox(height: 16),

              _buildImagePicker('Vehicle Registration', 'vehicle', _vehicleRegistration),
              const SizedBox(height: 32),

              CustomButton(
                onPressed: _submitApplication,
                text: 'Submit Application',
                isLoading: _isSubmitting,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}