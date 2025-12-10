import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/orders_provider.dart';
import '../../providers/auth_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrder(int.parse(widget.orderId));
    });
  }

  Future<void> _cancelOrder() async {
    final order = context.read<OrdersProvider>().selectedOrder;
    if (order == null) return;

    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                hintText: 'Why are you cancelling?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cancel Order',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<OrdersProvider>().cancelOrder(
            order.id,
            reason: reasonController.text.trim().isEmpty
                ? null
                : reasonController.text.trim(),
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully')),
        );
      }
    }

    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.id;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Consumer<OrdersProvider>(
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final order = ordersProvider.selectedOrder;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          final isBuyer = currentUserId == order.buyer.id;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Status Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: order.status.color.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getStatusIcon(order.status.value),
                        size: 60,
                        color: order.status.color,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.status.displayName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: order.status.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.status.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Order Number
                _buildInfoCard(
                  title: 'Order Number',
                  child: Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Item Details
                _buildInfoCard(
                  title: 'Item',
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: order.item.image ?? '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.itemPriceDisplay,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Buyer/Seller Info
                _buildInfoCard(
                  title: isBuyer ? 'Seller' : 'Buyer',
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          (isBuyer ? order.seller.name : order.buyer.name)[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
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
                              isBuyer ? order.seller.name : order.buyer.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if ((isBuyer ? order.seller.phone : order.buyer.phone) != null)
                              Text(
                                isBuyer ? order.seller.phone! : order.buyer.phone!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Delivery Address
                if (order.deliveryAddress != null)
                  _buildInfoCard(
                    title: 'Delivery Address',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.deliveryAddress!.addressLine1,
                          style: const TextStyle(fontSize: 15),
                        ),
                        if (order.deliveryAddress!.addressLine2 != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            order.deliveryAddress!.addressLine2!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${order.deliveryAddress!.city}, ${order.deliveryAddress!.country}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),

                // Order Summary
                _buildInfoCard(
                  title: 'Order Summary',
                  child: Column(
                    children: [
                      _buildSummaryRow('Item Price', order.itemPriceDisplay),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Delivery Fee', order.deliveryFeeDisplay),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'Total',
                        order.totalAmountDisplay,
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                // Payment Method
                _buildInfoCard(
                  title: 'Payment Method',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.money,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Cash on Delivery',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Order Date
                _buildInfoCard(
                  title: 'Order Date',
                  child: Text(
                    DateFormat('MMMM dd, yyyy - hh:mm a').format(order.createdAt),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),

                // Cancellation Info (if cancelled)
                if (order.isCancelled) ...[
                  _buildInfoCard(
                    title: 'Cancellation',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancelled on ${DateFormat('MMM dd, yyyy').format(order.cancelledAt!)}',
                          style: const TextStyle(fontSize: 15),
                        ),
                        if (order.cancellationReason != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Reason: ${order.cancellationReason}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),

      // Cancel Order Button
      bottomNavigationBar: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          final order = ordersProvider.selectedOrder;
          if (order == null || !order.canCancel) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _cancelOrder,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Theme.of(context).primaryColor : Colors.black,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'in_delivery':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle;
      case 'completed':
        return Icons.thumb_up_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }
}