import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../providers/items_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/category_enum.dart';
import '../../widgets/items/item_card.dart';
import '../../widgets/items/category_chip.dart';
import '../../widgets/items/empty_state.dart';
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
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              context.push('/favorites');
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              context.push('/cart');
            },
          ),
        ],
      ),

      body: Column(
        children: [
          const _StatsBar(),
          
          if (user != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user.name.split(' ').first}! 👋',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Find sustainable fashion',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Container(
            height: 50,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => _onCategorySelected(null),
                ),
                const SizedBox(width: 8),
                ...Category.all.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
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

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          size: 18,
                        ),
                        label: Text(
                          hasFilters ? 'Filters Applied' : 'Filter',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: hasFilters 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey[700],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<ItemsProvider>(
                    builder: (context, provider, child) {
                      return OutlinedButton.icon(
                        onPressed: _showSortOptions,
                        icon: const Icon(Icons.sort, size: 18),
                        label: Text(_getSortLabel(provider.sortBy)),
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
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create-item');
        },
        icon: const Icon(Icons.add),
        label: const Text('Sell Item'),
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
      final dio = Dio();
      final response = await dio.get('http://10.0.2.2:8000/api/admin/stats');
      setState(() {
        _stats = {
          'items_sold': response.data['data']['items_sold'] ?? 0,
          'total_donations': response.data['data']['total_donations'] ?? 0,
        };
        _isLoading = false;
      });
    } catch (e) {
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
        height: 80,
        color: Colors.green[50],
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBadge(
            icon: Icons.shopping_bag,
            label: 'Items Sold',
            value: '${_stats!['items_sold']}',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          _StatBadge(
            icon: Icons.favorite,
            label: 'Donations',
            value: '${_stats!['total_donations']}',
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}