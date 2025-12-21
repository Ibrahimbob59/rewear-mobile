import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/addresses_provider.dart';
import '../../models/address_model.dart';

class EditAddressScreen extends StatefulWidget {
  final String addressId;

  const EditAddressScreen({super.key, required this.addressId});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  late TextEditingController _phoneController;
  bool _isDefault = false;
  bool _isLoading = false;
  Address? _address;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  void _loadAddress() {
    final provider = context.read<AddressesProvider>();
    _address = provider.addresses.firstWhere(
      (a) => a.id.toString() == widget.addressId,
    );

    _addressLine1Controller = TextEditingController(text: _address!.addressLine1);
    _addressLine2Controller = TextEditingController(text: _address!.addressLine2 ?? '');
    _cityController = TextEditingController(text: _address!.city);
    _stateController = TextEditingController(text: _address!.state ?? '');
    _countryController = TextEditingController(text: _address!.country);
    _postalCodeController = TextEditingController(text: _address!.postalCode ?? '');
    _phoneController = TextEditingController(text: _address!.phoneNumber ?? '');
    _isDefault = _address!.isDefault;
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<AddressesProvider>().updateAddress(
      id: int.parse(widget.addressId),
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim().isEmpty
          ? null
          : _addressLine2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      country: _countryController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      isDefault: _isDefault,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address updated successfully')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AddressesProvider>().error ?? 'Failed to update',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_address == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Edit Address')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _addressLine1Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 1*',
                prefixIcon: Icon(Icons.home_outlined),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _addressLine2Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 2 (Optional)',
                prefixIcon: Icon(Icons.apartment_outlined),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City*',
                prefixIcon: Icon(Icons.location_city_outlined),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(
                labelText: 'State/Province (Optional)',
                prefixIcon: Icon(Icons.map_outlined),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Country*',
                prefixIcon: Icon(Icons.public),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'Postal Code (Optional)',
                prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone (Optional)',
                prefixIcon: Icon(Icons.phone_outlined),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text('Set as default address'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateAddress,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}