import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
    
    // Load items on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemsProvider>().loadItems(refresh: true);
    });

    // Setup pagination
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

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    
    final provider = context.read<ItemsProvider>();
    provider.setCategory(category);
    provider.applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      // App Bar
      appBar: AppBar(
        title: const Text(
          'ReWear',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search screen
              context.push('/search');
            },
          ),
          
          // Favorites
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              context.push('/favorites');
            },
          ),
          
          // Cart
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              context.push('/cart');
            },
          ),
        ],
      ),

      // Body
      body: Column(
        children: [
          // User greeting
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

          // Category Filters
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

          // Filter & Sort Bar
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
                        onPressed: () {
                          // TODO: Show sort options
                        },
                        icon: const Icon(Icons.sort, size: 18),
                        label: Text(
                          provider.sortBy == 'newest' 
                              ? 'Newest' 
                              : provider.sortBy == 'price_asc'
                                  ? 'Price: Low'
                                  : 'Price: High',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Items Grid
          Expanded(
            child: Consumer<ItemsProvider>(
              builder: (context, itemsProvider, child) {
                // Loading state
                if (itemsProvider.isLoading && itemsProvider.items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error state
                if (itemsProvider.error != null && itemsProvider.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'Oops!',
                    message: 'Something went wrong. Please try again.',
                    actionLabel: 'Retry',
                    onAction: () => itemsProvider.loadItems(refresh: true),
                  );
                }

                // Empty state
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

                // Items grid
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
                      // Show loading indicators at bottom
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

      // Floating Action Button
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