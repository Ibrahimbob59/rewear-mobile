import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/items_provider.dart';
import '../../models/item_model.dart';
import '../../widgets/items/item_card.dart';
import '../../widgets/items/empty_state.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemsProvider>().loadMyListings();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<ItemsProvider>().loadMyListings();
  }

  void _showItemOptions(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                item.status.value == 'available'
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              title: Text(
                item.status.value == 'available'
                    ? 'Mark as Unavailable'
                    : 'Mark as Available',
              ),
              onTap: () async {
                Navigator.pop(context);
                final success = await context
                    .read<ItemsProvider>()
                    .toggleItemStatus(item.id);

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Item marked as ${item.status.value == "available" ? "unavailable" : "available"}',
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
                context.push('/edit-item/${item.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Item'),
                    content: const Text(
                      'Are you sure you want to delete this item?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  final success = await context
                      .read<ItemsProvider>()
                      .deleteItem(item.id);

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item deleted successfully'),
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: Consumer<ItemsProvider>(
        builder: (context, itemsProvider, child) {
          // Loading state
          if (itemsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (itemsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    itemsProvider.error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (itemsProvider.myListings.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No listings yet',
              message: 'Start selling by creating your first listing!',
              actionLabel: 'Create Listing',
              onAction: () => context.push('/create-item'),
            );
          }

          // Listings grid
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: itemsProvider.myListings.length,
              itemBuilder: (context, index) {
                final item = itemsProvider.myListings[index];
                return GestureDetector(
                  onLongPress: () => _showItemOptions(context, item),
                  child: Stack(
                    children: [
                      ItemCard(
                        item: item,
                        onTap: () {
                          context.push('/item/${item.id}');
                        },
                      ),
                      
                      // Status Indicator
                      if (item.status.value != 'available')
                        Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: item.status.color.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.status.displayName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // More Options Button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _showItemOptions(context, item),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create-item');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
      ),
    );
  }
}