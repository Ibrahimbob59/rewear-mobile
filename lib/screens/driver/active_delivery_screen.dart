import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/delivery_provider.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final int deliveryId;
  
  const ActiveDeliveryScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  String? _notes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().loadDelivery(widget.deliveryId);
    });
  }

  Future<void> _handleConfirmPickup() async {
    final provider = context.read<DeliveryProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Pickup'),
        content: const Text('Have you picked up the item from the seller?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.confirmPickup(
        widget.deliveryId,
        notes: _notes,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup confirmed!'),
            backgroundColor: Colors.green,
          ),
        );
        await provider.loadDelivery(widget.deliveryId);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to confirm pickup'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleConfirmDelivery() async {
    final provider = context.read<DeliveryProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delivery'),
        content: const Text('Have you delivered the item to the buyer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.confirmDelivery(
        widget.deliveryId,
        notes: _notes,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery confirmed!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to confirm delivery'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Delivery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DeliveryProvider>().loadDelivery(widget.deliveryId);
            },
          ),
        ],
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, deliveryProvider, child) {
          if (deliveryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deliveryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(deliveryProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      deliveryProvider.loadDelivery(widget.deliveryId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final delivery = deliveryProvider.currentDelivery;

          if (delivery == null) {
            return const Center(
              child: Text('Delivery not found'),
            );
          }

          return _buildDeliveryDetails(delivery);
        },
      ),
    );
  }

  Widget _buildDeliveryDetails(Map<String, dynamic> delivery) {
    final status = delivery['status'] ?? 'unknown';
    final deliveryFee = (delivery['delivery_fee'] ?? 0).toDouble();
    final driverEarning = (delivery['driver_earning'] ?? 0).toDouble();
    final distanceKm = (delivery['distance_km'] ?? 0).toDouble();
    
    // Get order info
    final order = delivery['order'] as Map<String, dynamic>?;
    final orderNumber = order?['order_number'] ?? 'N/A';
    final item = order?['item'] as Map<String, dynamic>?;
    final itemTitle = item?['title'] ?? 'Unknown Item';
    
    // Get addresses
    final pickupAddress = delivery['pickup_address'] ?? 'Unknown';
    final deliveryAddress = delivery['delivery_address'] ?? 'Unknown';
    
    // Get contact info
    final seller = order?['seller'] as Map<String, dynamic>?;
    final buyer = order?['buyer'] as Map<String, dynamic>?;
    final sellerName = seller?['name'] ?? 'Unknown';
    final buyerName = buyer?['name'] ?? 'Unknown';
    final sellerPhone = seller?['phone'] ?? 'N/A';
    final buyerPhone = buyer?['phone'] ?? 'N/A';

    return SingleChildScrollView(
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
                      const Text(
                        'Delivery Status',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatStatus(status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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

          // Order Info
          _buildSectionTitle('Order Information'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow('Order Number', orderNumber),
                  const Divider(),
                  _buildInfoRow('Item', itemTitle),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Addresses
          _buildSectionTitle('Delivery Route'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAddressRow(
                    Icons.location_on_outlined,
                    'Pickup from Seller',
                    pickupAddress,
                    sellerName,
                    sellerPhone,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 2,
                    height: 30,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(left: 10),
                  ),
                  const SizedBox(height: 16),
                  _buildAddressRow(
                    Icons.location_on,
                    'Deliver to Buyer',
                    deliveryAddress,
                    buyerName,
                    buyerPhone,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Delivery Details
          _buildSectionTitle('Delivery Details'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  'Distance',
                  '${distanceKm.toStringAsFixed(1)} km',
                  Icons.route,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  'Total Fee',
                  '\$${deliveryFee.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Earning',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${driverEarning.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notes Field
          TextField(
            decoration: const InputDecoration(
              labelText: 'Delivery Notes (Optional)',
              hintText: 'Add any notes about this delivery...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              _notes = value;
            },
          ),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(status),
          const SizedBox(height: 16),

          // Cancel Button
          if (status == 'assigned' || status == 'in_transit')
            OutlinedButton(
              onPressed: () => _showCancelDialog(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Cancel Delivery'),
            ),
        ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(
    IconData icon,
    String label,
    String address,
    String contactName,
    String contactPhone,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contact: $contactName',
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                'Phone: $contactPhone',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    if (status == 'assigned') {
      return ElevatedButton(
        onPressed: _handleConfirmPickup,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.blue,
        ),
        child: const Text('Confirm Pickup'),
      );
    } else if (status == 'in_transit' || status == 'picked_up') {
      return ElevatedButton(
        onPressed: _handleConfirmDelivery,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.green,
        ),
        child: const Text('Confirm Delivery'),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return [Colors.blue[600]!, Colors.blue[400]!];
      case 'in_transit':
      case 'picked_up':
        return [Colors.orange[600]!, Colors.orange[400]!];
      case 'delivered':
        return [Colors.green[600]!, Colors.green[400]!];
      default:
        return [Colors.grey[600]!, Colors.grey[400]!];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Icons.assignment;
      case 'in_transit':
      case 'picked_up':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return 'Assigned';
      case 'in_transit':
        return 'In Transit';
      case 'picked_up':
        return 'Picked Up';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  Future<void> _showCancelDialog() async {
    String? cancellationReason;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this delivery?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason',
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
            child: const Text('Keep Delivery'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Delivery'),
          ),
        ],
      ),
    );

    if (confirmed == true && cancellationReason != null && cancellationReason!.isNotEmpty) {
      final provider = context.read<DeliveryProvider>();
      final success = await provider.cancelDelivery(
        widget.deliveryId,
        reason: cancellationReason!,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}