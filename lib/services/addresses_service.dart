import 'package:dio/dio.dart';
import '../models/address_model.dart';

class AddressesService {
  final Dio _dio;

  AddressesService(this._dio);

  // Get all user addresses
  Future<List<Address>> getAddresses() async {
    try {
      final response = await _dio.get('/addresses');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Address.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  // Create new address
  Future<Address> createAddress({
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
    try {
      final data = {
        'address_line1': addressLine1,
        if (addressLine2 != null) 'address_line2': addressLine2,
        'city': city,
        if (state != null) 'state': state,
        'country': country,
        if (postalCode != null) 'postal_code': postalCode,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'is_default': isDefault,
      };

      final response = await _dio.post('/addresses', data: data);
      return Address.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create address: $e');
    }
  }

  // Update address
  Future<Address> updateAddress({
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
    try {
      final data = <String, dynamic>{
        if (addressLine1 != null) 'address_line1': addressLine1,
        if (addressLine2 != null) 'address_line2': addressLine2,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
        if (postalCode != null) 'postal_code': postalCode,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (isDefault != null) 'is_default': isDefault,
      };

      final response = await _dio.put('/addresses/$id', data: data);
      return Address.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  // Delete address
  Future<void> deleteAddress(int id) async {
    try {
      await _dio.delete('/addresses/$id');
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }
}