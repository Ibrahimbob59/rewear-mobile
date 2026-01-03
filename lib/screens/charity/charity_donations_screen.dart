import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/items_provider.dart';
import '../../widgets/items/item_card.dart';
import '../../widgets/items/empty_state.dart';

class CharityDonationsScreen extends StatefulWidget {
  const CharityDonationsScreen({super.key});

  @override
  State<CharityDonationsScreen> createState() => _CharityDonationsScreenState();
}

class _CharityDonationsScreenState extends State<CharityDonationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ItemsProvider>();
      provider.setDonation(true); // Show only donations
      provider.applyFilters();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<ItemsProvider>().loadItems(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Donations'),
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

          if (provider.items.isEmpty) {
            return EmptyState(
              icon: Icons.card_giftcard,
              title: 'No donations available',
              message: 'Check back later for new donations',
              actionLabel: 'Refresh',
              onAction: _onRefresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap any item to view details and claim it for your charity',
                          style: TextStyle(
                            color: Colors.green[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final item = provider.items[index];
                      return ItemCard(
                        item: item,
                        onTap: () => context.push('/item/${item.id}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}