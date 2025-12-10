import 'package:flutter/foundation.dart';
import '../models/address_model.dart';
import '../services/addresses_service.dart';

class AddressesProvider with ChangeNotifier {
  final AddressesService _addressesService;

  AddressesProvider(this._addressesService);

  // State
  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;
  Address? get defaultAddress => 
      _addresses.where((addr) => addr.isDefault).firstOrNull;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAddresses => _addresses.isNotEmpty;

  // Load all addresses
  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _addressesService.getAddresses();
      
      // Set default address as selected if none selected
      if (_selectedAddress == null && defaultAddress != null) {
        _selectedAddress = defaultAddress;
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading addresses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create address
  Future<bool> createAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    String? state,
    required String country,
    String? postalCode,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAddress = await _addressesService.createAddress(
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        phoneNumber: phoneNumber,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      _addresses.add(newAddress);
      
      // If this is the only address or set as default, select it
      if (_addresses.length == 1 || isDefault) {
        _selectedAddress = newAddress;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating address: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update address
  Future<bool> updateAddress({
    required int id,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAddress = await _addressesService.updateAddress(
        id: id,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        phoneNumber: phoneNumber,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      final index = _addresses.indexWhere((addr) => addr.id == id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        
        // Update selected address if it's the one being updated
        if (_selectedAddress?.id == id) {
          _selectedAddress = updatedAddress;
        }
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating address: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete address
  Future<bool> deleteAddress(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _addressesService.deleteAddress(id);
      
      _addresses.removeWhere((addr) => addr.id == id);
      
      // Clear selected address if it was deleted
      if (_selectedAddress?.id == id) {
        _selectedAddress = defaultAddress;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting address: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select address
  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  // Clear selected address
  void clearSelectedAddress() {
    _selectedAddress = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}