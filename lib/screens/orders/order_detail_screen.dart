import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/auth_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

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
      context.read<OrdersProvider>().loadOrder(widget.orderId);
    });
  }

  Future<void> _handleCancelOrder() async {
    String cancellationReason = '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                cancellationReason = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep Order'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed == true && cancellationReason.isNotEmpty) {
      final ordersProvider = context.read<OrdersProvider>();

      try {
        final success = await ordersProvider.cancelOrder(
          widget.orderId,
          cancellationReason,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Reload order details
          await ordersProvider.loadOrder(widget.orderId);
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel order: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (confirmed == true && cancellationReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a cancellation reason'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrdersProvider>().loadOrder(widget.orderId);
            },
          ),
        ],
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ordersProvider.loadOrder(widget.orderId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = ordersProvider.selectedOrder;

          if (order == null) {
            return const Center(
              child: Text('Order not found'),
            );
          }

          // Check if current user is buyer or seller
          final authProvider = context.read<AuthProvider>();
          final currentUserId = authProvider.user?.id;
          final buyer = order['buyer'] as Map<String, dynamic>?;
          final seller = order['seller'] as Map<String, dynamic>?;
          final isBuyer = currentUserId == buyer?['id'];

          return _buildOrderDetails(order, isBuyer);
        },
      ),
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> order, bool isBuyer) {
    final status = order['status'] ?? 'unknown';
    final orderNumber = order['order_number'] ?? 'N/A';
    
    // Get status properties
    final isCompleted = status == 'completed';
    final isDelivered = status == 'delivered';
    final isInDelivery = status == 'in_delivery';
    final isPending = status == 'pending';
    final isConfirmed = status == 'confirmed';
    final isCancelled = status == 'cancelled';
    
    // Can cancel if pending or confirmed
    final canCancel = (isPending || isConfirmed) && isBuyer;
    
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<OrdersProvider>().loadOrder(widget.orderId);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getStatusColors(status),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #$orderNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatStatus(status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Item Card
            _buildSectionTitle('Item Details'),
            const SizedBox(height: 12),
            _buildItemCard(order),
            const SizedBox(height: 24),

            // Parties Involved
            _buildSectionTitle(isBuyer ? 'Seller Information' : 'Buyer Information'),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final buyer = order['buyer'] as Map<String, dynamic>?;
              final seller = order['seller'] as Map<String, dynamic>?;
              return _buildPartyCard(isBuyer ? seller : buyer);
            }),            
            const SizedBox(height: 24),

            // Delivery Address
            if (order['delivery_address'] != null) ...[
              _buildSectionTitle('Delivery Address'),
              const SizedBox(height: 12),
              _buildDeliveryAddressCard(order['delivery_address']),
              const SizedBox(height: 24),
            ],

            // Price Breakdown
            _buildSectionTitle('Price Details'),
            const SizedBox(height: 12),
            _buildPriceCard(order),
            const SizedBox(height: 24),

            // Timeline
            _buildSectionTitle('Order Timeline'),
            const SizedBox(height: 12),
            _buildTimelineCard(order),
            const SizedBox(height: 24),

            // Cancellation Info
            if (isCancelled) ...[
              _buildCancellationCard(order),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (canCancel)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleCancelOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel Order'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> order) {
    final item = order['item'] as Map<String, dynamic>?;

    if (item == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Item details not available'),
        ),
      );
    }

    final title = item['title'] ?? 'Unknown Item';
    final description = item['description'] ?? '';
    final price = double.tryParse(order['item_price']?.toString() ?? '0') ?? 0.0;
    final images = item['images'] as List?;
    final condition = item['condition'] ?? '';
    final size = item['size'] ?? '';
    final category = item['category'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (images != null && images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  images.first,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 60),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Price
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            if (description.isNotEmpty) ...[
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Details
            if (condition.isNotEmpty || size.isNotEmpty || category.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              if (category.isNotEmpty)
                _buildDetailRow('Category', category),
              if (condition.isNotEmpty)
                _buildDetailRow('Condition', _formatCondition(condition)),
              if (size.isNotEmpty)
                _buildDetailRow('Size', size),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPartyCard(Map<String, dynamic>? party) {
    if (party == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Information not available'),
        ),
      );
    }

    final name = party['name'] ?? 'Unknown';
    final email = party['email'] ?? '';
    final phone = party['phone'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(phone, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressCard(dynamic addressData) {
    final address = addressData as Map<String, dynamic>?;
    
    if (address == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Address not available'),
        ),
      );
    }

    final fullName = address['full_name'] ?? '';
    final phone = address['phone'] ?? '';
    final street = address['street'] ?? '';
    final city = address['city'] ?? '';
    final state = address['state'] ?? '';
    final zipCode = address['zip_code'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fullName.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (phone.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.phone, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(phone),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$street, $city, $state $zipCode',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(Map<String, dynamic> order) {
    final itemPrice = double.tryParse(order['item_price']?.toString() ?? '0') ?? 0.0;
    final deliveryFee = double.tryParse(order['delivery_fee']?.toString() ?? '0') ?? 0.0;
    final totalAmount = double.tryParse(order['total_amount']?.toString() ?? '0') ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPriceRow('Item Price', '\$${itemPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildPriceRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> order) {
    final createdAt = order['created_at'] ?? '';
    final confirmedAt = order['confirmed_at'];
    final deliveredAt = order['delivered_at'];
    final completedAt = order['completed_at'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTimelineItem(
              'Order Placed',
              _formatDateTime(createdAt),
              true,
            ),
            if (confirmedAt != null)
              _buildTimelineItem(
                'Order Confirmed',
                _formatDateTime(confirmedAt),
                true,
              ),
            if (deliveredAt != null)
              _buildTimelineItem(
                'Order Delivered',
                _formatDateTime(deliveredAt),
                true,
              ),
            if (completedAt != null)
              _buildTimelineItem(
                'Order Completed',
                _formatDateTime(completedAt),
                true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationCard(Map<String, dynamic> order) {
    final isCancelled = order['status'] == 'cancelled';
    
    if (!isCancelled) return const SizedBox.shrink();

    final cancelledAt = order['cancelled_at'] ?? '';
    final reason = order['cancellation_reason'] ?? 'No reason provided';

    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cancel, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'Order Cancelled',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            if (cancelledAt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Cancelled on: ${_formatDateTime(cancelledAt)}'),
            ],
            const SizedBox(height: 8),
            const Text(
              'Reason:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(reason),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return [Colors.orange[600]!, Colors.orange[400]!];
      case 'confirmed':
        return [Colors.blue[600]!, Colors.blue[400]!];
      case 'in_delivery':
        return [Colors.purple[600]!, Colors.purple[400]!];
      case 'delivered':
        return [Colors.green[600]!, Colors.green[400]!];
      case 'completed':
        return [Colors.teal[600]!, Colors.teal[400]!];
      case 'cancelled':
        return [Colors.red[600]!, Colors.red[400]!];
      default:
        return [Colors.grey[600]!, Colors.grey[400]!];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'in_delivery':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'completed':
        return Icons.verified;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_delivery':
        return 'In Delivery';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return 'New';
      case 'like_new':
        return 'Like New';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      default:
        return condition;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}