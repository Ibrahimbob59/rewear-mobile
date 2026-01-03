import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/items_provider.dart';
import '../../widgets/items/item_card.dart';
import '../../widgets/items/empty_state.dart';

class SellingScreen extends StatefulWidget {
  const SellingScreen({super.key});

  @override
  State<SellingScreen> createState() => _SellingScreenState();
}

class _SellingScreenState extends State<SellingScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Sales'),
      ),
      body: Consumer<ItemsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.myListings.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No listings yet',
              message: 'Start selling by creating your first listing',
              actionLabel: 'Create Listing',
              onAction: () => context.push('/create-item'),
            );
          }

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
              itemCount: provider.myListings.length,
              itemBuilder: (context, index) {
                final item = provider.myListings[index];
                return ItemCard(
                  item: item,
                  onTap: () => context.push('/item/${item.id}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-item'),
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
      ),
    );
  }
}