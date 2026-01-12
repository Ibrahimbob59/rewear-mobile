import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/items_provider.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/items/item_card.dart';
import '../../widgets/items/empty_state.dart';

class SellingScreen extends StatefulWidget {
  const SellingScreen({super.key});

  @override
  State<SellingScreen> createState() => _SellingScreenState();
}

class _SellingScreenState extends State<SellingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final itemsProvider = context.read<ItemsProvider>();
    final ordersProvider = context.read<OrdersProvider>();
    await Future.wait([
      itemsProvider.loadMyListings(),
      ordersProvider.loadSellerOrders(),
    ]);
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Selling'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'My Listings'),
            Tab(text: 'Sales'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListingsTab(),
          _buildSalesTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/create-item'),
              icon: const Icon(Icons.add),
              label: const Text('New Listing'),
            )
          : null,
    );
  }

  Widget _buildListingsTab() {
    return Consumer<ItemsProvider>(
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
    );
  }

  Widget _buildSalesTab() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(ordersProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _onRefresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (ordersProvider.sellerOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No sales yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Items you\'ve sold will appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.sellerOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.sellerOrders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderNumber = order['order_number'] ?? 'N/A';
    final status = order['status'] ?? 'unknown';
    final totalAmount = double.tryParse(order['total_amount']?.toString() ?? '0') ?? 0.0;
    final createdAt = order['created_at'] ?? '';

    // Get item info
    final itemData = order['item'];
    String itemTitle = 'Unknown Item';
    String? itemImage;

    if (itemData is Map<String, dynamic>) {
      itemTitle = itemData['title'] ?? 'Unknown Item';
      if (itemData['image'] != null) {
        itemImage = itemData['image'].toString();
      } else if (itemData['images'] is List && (itemData['images'] as List).isNotEmpty) {
        itemImage = (itemData['images'] as List).first?.toString();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          final orderId = order['id'];
          if (orderId != null) {
            context.push('/orders/$orderId');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image
              if (itemImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    itemImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, size: 40),
                    ),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              const SizedBox(width: 12),

              // Order Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #$orderNumber',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusChip(status),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        label = 'Pending';
        break;
      case 'confirmed':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        label = 'Confirmed';
        break;
      case 'in_delivery':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        label = 'In Delivery';
        break;
      case 'delivered':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        label = 'Delivered';
        break;
      case 'completed':
        backgroundColor = Colors.teal[100]!;
        textColor = Colors.teal[700]!;
        label = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        label = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}