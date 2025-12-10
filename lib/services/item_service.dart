import 'dart:io';
import 'package:dio/dio.dart';
import '../models/item_model.dart';

class ItemsService {
  final Dio _dio;

  ItemsService(this._dio);

  // Get all items with filters
  Future<List<Item>> getItems({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? size,
    String? condition,
    String? gender,
    bool? isDonation,
    double? userLat,
    double? userLng,
    double? radiusKm,
    String? sortBy, // newest, price_asc, price_desc, nearest
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (search != null) 'search': search,
        if (category != null) 'category': category,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (size != null) 'size': size,
        if (condition != null) 'condition': condition,
        if (gender != null) 'gender': gender,
        if (isDonation != null) 'is_donation': isDonation,
        if (userLat != null) 'user_lat': userLat,
        if (userLng != null) 'user_lng': userLng,
        if (radiusKm != null) 'radius_km': radiusKm,
        if (sortBy != null) 'sort_by': sortBy,
        'page': page,
        'per_page': perPage,
      };

      final response = await _dio.get('/items', queryParameters: queryParams);

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Item.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  // Get single item by ID
  Future<Item> getItem(int id) async {
    try {
      final response = await _dio.get('/items/$id');
      return Item.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch item: $e');
    }
  }

  // Create new item (with images)
  Future<Item> createItem({
    required String title,
    required String description,
    required String category,
    required String size,
    required String condition,
    String? gender,
    String? brand,
    String? color,
    double? price,
    required bool isDonation,
    required List<File> images,
  }) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'category': category,
        'size': size,
        'condition': condition,
        if (gender != null) 'gender': gender,
        if (brand != null) 'brand': brand,
        if (color != null) 'color': color,
        if (price != null) 'price': price,
        'is_donation': isDonation,
      });

      // Add images
      for (int i = 0; i < images.length; i++) {
        formData.files.add(
          MapEntry(
            'images[$i]',
            await MultipartFile.fromFile(
              images[i].path,
              filename: 'image_$i.jpg',
            ),
          ),
        );
      }

      final response = await _dio.post('/items', data: formData);
      return Item.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  // Update item
  Future<Item> updateItem({
    required int id,
    String? title,
    String? description,
    String? category,
    String? size,
    String? condition,
    String? gender,
    String? brand,
    String? color,
    double? price,
  }) async {
    try {
      final data = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (size != null) 'size': size,
        if (condition != null) 'condition': condition,
        if (gender != null) 'gender': gender,
        if (brand != null) 'brand': brand,
        if (color != null) 'color': color,
        if (price != null) 'price': price,
      };

      final response = await _dio.put('/items/$id', data: data);
      return Item.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // Delete item
  Future<void> deleteItem(int id) async {
    try {
      await _dio.delete('/items/$id');
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // Get user's own listings
  Future<List<Item>> getMyListings() async {
    try {
      final response = await _dio.get('/items/my-listings');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Item.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch my listings: $e');
    }
  }

  // Toggle item status (available/unavailable)
  Future<Item> toggleItemStatus(int id) async {
    try {
      final response = await _dio.post('/items/$id/toggle-status');
      return Item.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to toggle item status: $e');
    }
  }
}