import 'package:dio/dio.dart';
import '../models/item_model.dart';

class FavoritesService {
  final Dio _dio;

  FavoritesService(this._dio);

  // Add item to favorites
  Future<void> addFavorite(int itemId) async {
    try {
      await _dio.post('/favorites/$itemId');
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  // Remove item from favorites
  Future<void> removeFavorite(int itemId) async {
    try {
      await _dio.delete('/favorites/$itemId');
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // Get all favorites
  Future<List<Item>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Item.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  // Toggle favorite (add if not favorited, remove if favorited)
  Future<bool> toggleFavorite(int itemId, bool currentStatus) async {
    try {
      if (currentStatus) {
        await removeFavorite(itemId);
        return false;
      } else {
        await addFavorite(itemId);
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }
}