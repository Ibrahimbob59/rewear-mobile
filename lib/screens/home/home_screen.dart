import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../providers/items_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/category_enum.dart';
import '../../widgets/items/item_card.dart';
import '../../widgets/items/category_chip.dart';
import '../../widgets/items/empty_state.dart';
import '../../services/api_service.dart';
import 'filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemsProvider>().loadItems(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ItemsProvider>().loadMoreItems();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<ItemsProvider>().loadItems(refresh: true);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final provider = context.read<ItemsProvider>();
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _SortOption(
                title: 'Newest First',
                isSelected: provider.sortBy == 'newest',
                onTap: () {
                  provider.setSortBy('newest');
                  provider.applyFilters();
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'Oldest First',
                isSelected: provider.sortBy == 'oldest',
                onTap: () {
                  provider.setSortBy('oldest');
                  provider.applyFilters();
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'Price: Low to High',
                isSelected: provider.sortBy == 'price_low',
                onTap: () {
                  provider.setSortBy('price_low');
                  provider.applyFilters();
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'Price: High to Low',
                isSelected: provider.sortBy == 'price_high',
                onTap: () {
                  provider.setSortBy('price_high');
                  provider.applyFilters();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    
    final provider = context.read<ItemsProvider>();
    provider.setCategory(category);
    provider.applyFilters();
  }

  String _getSortLabel(String? sortBy) {
    switch (sortBy) {
      case 'oldest':
        return 'Oldest';
      case 'price_low':
        return 'Price ↑';
      case 'price_high':
        return 'Price ↓';
      default:
        return 'Newest';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      appBar: AppBar(
        title: const Text(
          'ReWear',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              context.push('/favorites');
            },
          ),

          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () {
                      context.push('/cart');
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cart.itemCount > 99 ? '99+' : cart.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Search bar - more compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                context.push('/search');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[500], size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Search for items...',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // User greeting - more compact
          if (user != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hello, ${user.name.split(' ').first}!',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Find sustainable fashion',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Categories - more compact
          Container(
            height: 38,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => _onCategorySelected(null),
                ),
                const SizedBox(width: 6),
                ...Category.all.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: CategoryChip(
                      label: category.displayName,
                      isSelected: _selectedCategory == category.value,
                      onTap: () => _onCategorySelected(category.value),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter and Sort buttons - more compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Consumer<ItemsProvider>(
                    builder: (context, provider, child) {
                      final hasFilters = provider.selectedSize != null ||
                          provider.selectedCondition != null ||
                          provider.minPrice != null ||
                          provider.maxPrice != null;

                      return OutlinedButton.icon(
                        onPressed: _showFilterSheet,
                        icon: Icon(
                          hasFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                          size: 16,
                        ),
                        label: Text(
                          hasFilters ? 'Filters' : 'Filter',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: hasFilters
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Consumer<ItemsProvider>(
                    builder: (context, provider, child) {
                      return OutlinedButton.icon(
                        onPressed: _showSortOptions,
                        icon: const Icon(Icons.sort, size: 16),
                        label: Text(
                          _getSortLabel(provider.sortBy),
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer<ItemsProvider>(
              builder: (context, itemsProvider, child) {
                if (itemsProvider.isLoading && itemsProvider.items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (itemsProvider.error != null && itemsProvider.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'Oops!',
                    message: 'Something went wrong. Please try again.',
                    actionLabel: 'Retry',
                    onAction: () => itemsProvider.loadItems(refresh: true),
                  );
                }

                if (itemsProvider.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No items found',
                    message: 'Try adjusting your filters or check back later.',
                    actionLabel: 'Clear Filters',
                    onAction: () {
                      itemsProvider.clearFilters();
                      itemsProvider.applyFilters();
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: itemsProvider.items.length + 
                        (itemsProvider.isLoadingMore ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= itemsProvider.items.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final item = itemsProvider.items[index];
                      return ItemCard(
                        item: item,
                        onTap: () {
                          context.push('/item/${item.id}');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          
          const _StatsBar(),
        ],
      ),

    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: onTap,
    );
  }
}

class _StatsBar extends StatefulWidget {
  const _StatsBar();

  @override
  State<_StatsBar> createState() => _StatsBarState();
}

class _StatsBarState extends State<_StatsBar> {
  Map<String, int>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final apiService = ApiService();
      final response = await apiService.dio.get('/admin/stats');

      if (!mounted) return;

      setState(() {
        _stats = {
          'items_sold': response.data['data']['total_items_sold'] ?? 0,
          'total_donations': response.data['data']['total_donations'] ?? 0,
        };
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Set default values on error, still show the widget
      setState(() {
        _stats = {'items_sold': 0, 'total_donations': 0};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: const Center(
          child: SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.shopping_bag_outlined,
              label: 'Sold',
              value: '${_stats!['items_sold']}',
              color: const Color(0xFF2A9D8F),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.volunteer_activism_outlined,
              label: 'Donated',
              value: '${_stats!['total_donations']}',
              color: const Color(0xFFE76F51),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}