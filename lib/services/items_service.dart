import 'package:dio/dio.dart';
import 'dart:io';
import '../models/item_model.dart';
import 'api_service.dart';

class ItemsService {
  final Dio _dio = ApiService().dio;

  ItemsService(Dio dio);

  // Browse items (PUBLIC - No auth required)
  Future<Map<String, dynamic>> getItems({
    String? search,
    String? category,
    String? size,
    String? condition,
    String? gender,
    bool? isDonation,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null) 'category': category,
        if (size != null) 'size': size,
        if (condition != null) 'condition': condition,
        if (gender != null) 'gender': gender,
        // ⚠️ REMOVED: Backend doesn't support is_donation parameter
        // Will filter client-side instead
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (sortBy != null) 'sort_by': sortBy,
      };

      print('🔍 Fetching items: $queryParams');
      if (isDonation == true) {
        print('   ⚠️ isDonation filter requested but backend doesn\'t support it');
        print('   ℹ️ Will filter client-side after fetching');
      }

      final response = await _dio.get('/items', queryParameters: queryParams);

      print('✅ Response received: ${response.statusCode}');
      print('📦 Data structure: ${response.data.runtimeType}');

      // Backend returns: { "success": true, "message": "...", "data": { "items": [...] }, "meta": {...} }
      final data = response.data['data'];
      List<Item> items = (data['items'] as List)
          .map((json) => Item.fromJson(json))
          .toList();

      // Client-side filter for donations (since backend doesn't support it)
      if (isDonation == true) {
        items = items.where((item) => item.isDonation == true).toList();
        print('   ✓ Filtered to ${items.length} donation items (client-side)');
      }

      return {
        'items': items,
        'meta': response.data['meta'] ?? {},
      };
    } catch (e, stackTrace) {
      print('❌ Error fetching items: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  // Get single item (PUBLIC)
  Future<Item> getItem(int id) async {
    try {
      final response = await _dio.get('/items/$id');
      return Item.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error fetching item $id: $e');
      rethrow;
    }
  }

  // Create item (AUTH REQUIRED)
  Future<Item> createItem({
    required String title,
    required String description,
    required String category,
    required String size,
    required String condition,
    required bool isDonation,
    required List<File> images,
    String? gender,
    String? brand,
    String? color,
    double? price,
    int? donationQuantity,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'category': category,
        'size': size,
        'condition': condition,
        'is_donation': isDonation ? '1' : '0',
        if (gender != null) 'gender': gender,
        if (brand != null) 'brand': brand,
        if (color != null) 'color': color,
        if (price != null) 'price': price,
        if (isDonation && donationQuantity != null) 'donation_quantity': donationQuantity,
      });

      // Add images as array - use the same key 'images[]' for each file
      for (var i = 0; i < images.length; i++) {
        formData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(images[i].path),
        ));
      }

      print('📤 Creating item with is_donation=${isDonation ? '1' : '0'} (sent as string), donation_quantity=$donationQuantity, price=$price');
      print('📤 Images count: ${images.length}');

      final response = await _dio.post('/items', data: formData);
      return Item.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error creating item: $e');
      if (e is DioException) {
        print('❌ Response data: ${e.response?.data}');
        print('❌ Status code: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  // Update item (AUTH REQUIRED)
  Future<Item> updateItem({
    required int id,
    String? title,
    String? description,
    double? price,
    String? condition,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (condition != null) data['condition'] = condition;

      final response = await _dio.put('/items/$id', data: data);
      return Item.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error updating item: $e');
      rethrow;
    }
  }

  // Delete item (AUTH REQUIRED)
  Future<void> deleteItem(int id) async {
    try {
      await _dio.delete('/items/$id');
    } catch (e) {
      print('❌ Error deleting item: $e');
      rethrow;
    }
  }

  // Get my listings (AUTH REQUIRED)
  Future<List<Item>> getMyListings() async {
    try {
      final response = await _dio.get('/items/my-listings');

      print('✅ My listings response received: ${response.statusCode}');
      print('📦 Data structure: ${response.data.runtimeType}');

      // Backend returns: { "success": true, "data": { "items": [...] } }
      final data = response.data['data'];

      // Handle different response structures
      if (data is List) {
        // Direct list response
        return data.map((json) => Item.fromJson(json)).toList();
      } else if (data is Map) {
        // Wrapped in a map with 'items' key
        final items = data['items'] as List;
        return items.map((json) => Item.fromJson(json)).toList();
      }

      throw Exception('Unexpected response structure');
    } catch (e) {
      print('❌ Error fetching my listings: $e');
      rethrow;
    }
  }

  // Toggle status (AUTH REQUIRED)
  Future<Item> toggleItemStatus(int id) async {
    try {
      final response = await _dio.post('/items/$id/toggle-status');
      return Item.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error toggling status: $e');
      rethrow;
    }
  }
}