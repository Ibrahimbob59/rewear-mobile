import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/items_service.dart';

class ItemsProvider with ChangeNotifier {
  final ItemsService _itemsService;

  ItemsProvider(this._itemsService);

  List<Item> _items = [];
  List<Item> _myListings = [];
  Item? _selectedItem;
  Map<String, dynamic>? _meta;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Filters
  String? _searchQuery;
  String? _selectedCategory;
  String? _selectedSize;
  String? _selectedCondition;
  String? _selectedGender;
  bool? _isDonation;
  double? _minPrice;
  double? _maxPrice;
  String? _sortBy;
  int _currentPage = 1;

  // Getters
  List<Item> get items => _items;
  List<Item> get myListings => _myListings;
  Item? get selectedItem => _selectedItem;
  Map<String, dynamic>? get meta => _meta;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => (_meta?['last_page'] as int?) ?? 1;
  int get totalItems => (_meta?['total'] as int?) ?? 0;
  bool get hasMore => _currentPage < totalPages;

  // Filter getters
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedSize => _selectedSize;
  String? get selectedCondition => _selectedCondition;
  String? get selectedGender => _selectedGender;
  bool? get isDonation => _isDonation;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get sortBy => _sortBy;

  // Filter setters
  void setCategory(String? category) {
    _selectedCategory = category;
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

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
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

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> applyFilters() async {
    await loadItems(refresh: true);
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _selectedSize = null;
    _selectedCondition = null;
    _selectedGender = null;
    _isDonation = null;
    _minPrice = null;
    _maxPrice = null;
    _sortBy = null;
    notifyListeners();
  }

  // Load items
  Future<void> loadItems({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _items.clear();
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _error = null;
    notifyListeners();

    try {
      final result = await _itemsService.getItems(
        search: _searchQuery,
        category: _selectedCategory,
        size: _selectedSize,
        condition: _selectedCondition,
        gender: _selectedGender,
        isDonation: _isDonation,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _sortBy,
        page: _currentPage,
      );

      final newItems = result['items'] as List<Item>;
      _meta = result['meta'] as Map<String, dynamic>?;

      if (refresh) {
        _items = newItems;
      } else {
        _items.addAll(newItems);
      }

      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;
    _currentPage++;
    await loadItems();
  }

  Future<void> loadMoreItems() async => await loadMore();

  Future<void> refreshItems() async => await loadItems(refresh: true);

  Future<void> loadItem(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedItem = await _itemsService.getItem(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyListings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myListings = await _itemsService.getMyListings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createItem({
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
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final item = await _itemsService.createItem(
        title: title,
        description: description,
        category: category,
        size: size,
        condition: condition,
        isDonation: isDonation,
        images: images,
        gender: gender,
        brand: brand,
        color: color,
        price: price,
      );

      _myListings.insert(0, item);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem({
    required int id,
    String? title,
    String? description,
    double? price,
    String? condition,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final item = await _itemsService.updateItem(
        id: id,
        title: title,
        description: description,
        price: price,
        condition: condition,
      );

      final index = _myListings.indexWhere((i) => i.id == id);
      if (index != -1) _myListings[index] = item;

      final itemsIndex = _items.indexWhere((i) => i.id == id);
      if (itemsIndex != -1) _items[itemsIndex] = item;

      if (_selectedItem?.id == id) _selectedItem = item;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      await _itemsService.deleteItem(id);
      _myListings.removeWhere((i) => i.id == id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleItemStatus(int id) async {
    try {
      final item = await _itemsService.toggleItemStatus(id);
      final index = _myListings.indexWhere((i) => i.id == id);
      if (index != -1) _myListings[index] = item;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedItem() {
    _selectedItem = null;
    notifyListeners();
  }
}