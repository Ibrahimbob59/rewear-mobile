import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/items_service.dart';

class ItemsProvider with ChangeNotifier {
  final ItemsService _itemsService;

  ItemsProvider(this._itemsService);

  // State
  List<Item> _items = [];
  List<Item> _myListings = [];
  Item? _selectedItem;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;

  // Filters
  String? _searchQuery;
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedSize;
  String? _selectedCondition;
  String? _selectedGender;
  bool? _isDonation;
  String? _sortBy = 'newest';

  // Getters
  List<Item> get items => _items;
  List<Item> get myListings => _myListings;
  Item? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;

  // Filter getters
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get selectedSize => _selectedSize;
  String? get selectedCondition => _selectedCondition;
  String? get selectedGender => _selectedGender;
  bool? get isDonation => _isDonation;
  String? get sortBy => _sortBy;

  // Load items with filters
  Future<void> loadItems({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
      _items.clear();
    }

    if (!_hasMorePages) return;

    if (_currentPage == 1) {
      _isLoading = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final newItems = await _itemsService.getItems(
        search: _searchQuery,
        category: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        size: _selectedSize,
        condition: _selectedCondition,
        gender: _selectedGender,
        isDonation: _isDonation,
        sortBy: _sortBy,
        page: _currentPage,
        perPage: 20,
      );

      if (newItems.isEmpty) {
        _hasMorePages = false;
      } else {
        if (refresh) {
          _items = newItems;
        } else {
          _items.addAll(newItems);
        }
        _currentPage++;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading items: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load more items (pagination)
  Future<void> loadMoreItems() async {
    if (!_isLoadingMore && _hasMorePages) {
      await loadItems();
    }
  }

  // Get single item
  Future<void> loadItem(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedItem = await _itemsService.getItem(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading item: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create item
  Future<bool> createItem({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _itemsService.createItem(
        title: title,
        description: description,
        category: category,
        size: size,
        condition: condition,
        gender: gender,
        brand: brand,
        color: color,
        price: price,
        isDonation: isDonation,
        images: images,
      );

      _error = null;
      // Refresh my listings
      await loadMyListings();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating item: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update item
  Future<bool> updateItem({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _itemsService.updateItem(
        id: id,
        title: title,
        description: description,
        category: category,
        size: size,
        condition: condition,
        gender: gender,
        brand: brand,
        color: color,
        price: price,
      );

      _error = null;
      await loadMyListings();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating item: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete item
  Future<bool> deleteItem(int id) async {
    try {
      await _itemsService.deleteItem(id);
      _myListings.removeWhere((item) => item.id == id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting item: $e');
      notifyListeners();
      return false;
    }
  }

  // Load my listings
  Future<void> loadMyListings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myListings = await _itemsService.getMyListings();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading my listings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle item status
  Future<bool> toggleItemStatus(int id) async {
    try {
      final updatedItem = await _itemsService.toggleItemStatus(id);
      
      // Update in my listings
      final index = _myListings.indexWhere((item) => item.id == id);
      if (index != -1) {
        _myListings[index] = updatedItem;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error toggling item status: $e');
      return false;
    }
  }

  // Set filters
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setSize(String? size) {
    _selectedSize = size;
    notifyListeners();
  }

  void setCondition(String? condition) {
    _selectedCondition = condition;
    notifyListeners();
  }

  void setGender(String? gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setDonation(bool? isDonation) {
    _isDonation = isDonation;
    notifyListeners();
  }

  void setSortBy(String? sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedSize = null;
    _selectedCondition = null;
    _selectedGender = null;
    _isDonation = null;
    _sortBy = 'newest';
    notifyListeners();
  }

  // Apply filters and reload
  Future<void> applyFilters() async {
    await loadItems(refresh: true);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}