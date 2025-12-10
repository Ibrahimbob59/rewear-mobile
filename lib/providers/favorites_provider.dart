import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/favorites_service.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesService _favoritesService;

  FavoritesProvider(this._favoritesService);

  // State
  List<Item> _favorites = [];
  bool _isLoading = false;
  String? _error;
  
  // Track favorite item IDs for quick lookup
  final Set<int> _favoriteItemIds = {};

  // Getters
  List<Item> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get favoriteCount => _favorites.length;

  // Check if item is favorited
  bool isFavorite(int itemId) {
    return _favoriteItemIds.contains(itemId);
  }

  // Load all favorites
  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await _favoritesService.getFavorites();
      
      // Update favorite IDs set
      _favoriteItemIds.clear();
      _favoriteItemIds.addAll(_favorites.map((item) => item.id));
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite
  Future<bool> toggleFavorite(int itemId) async {
    final currentStatus = isFavorite(itemId);

    try {
      final newStatus = await _favoritesService.toggleFavorite(
        itemId,
        currentStatus,
      );

      if (newStatus) {
        // Added to favorites
        _favoriteItemIds.add(itemId);
      } else {
        // Removed from favorites
        _favoriteItemIds.remove(itemId);
        _favorites.removeWhere((item) => item.id == itemId);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error toggling favorite: $e');
      notifyListeners();
      return false;
    }
  }

  // Add to favorites
  Future<bool> addFavorite(int itemId) async {
    if (isFavorite(itemId)) return false;

    try {
      await _favoritesService.addFavorite(itemId);
      _favoriteItemIds.add(itemId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding favorite: $e');
      notifyListeners();
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFavorite(int itemId) async {
    if (!isFavorite(itemId)) return false;

    try {
      await _favoritesService.removeFavorite(itemId);
      _favoriteItemIds.remove(itemId);
      _favorites.removeWhere((item) => item.id == itemId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error removing favorite: $e');
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}