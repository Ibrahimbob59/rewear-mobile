import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/delivery_provider.dart';

class AvailableDeliveriesScreen extends StatefulWidget {
  const AvailableDeliveriesScreen({super.key});

  @override
  State<AvailableDeliveriesScreen> createState() => _AvailableDeliveriesScreenState();
}

class _AvailableDeliveriesScreenState extends State<AvailableDeliveriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().loadAvailableDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Deliveries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DeliveryProvider>().loadAvailableDeliveries();
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
                      deliveryProvider.loadAvailableDeliveries();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final deliveries = deliveryProvider.availableDeliveries;

          if (deliveries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No deliveries available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'New delivery requests will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await deliveryProvider.loadAvailableDeliveries();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final delivery = deliveries[index];
                // FIXED: Changed from Delivery type to Map<String, dynamic>
                return _buildDeliveryCard(delivery);
              },
            ),
          );
        },
      ),
    );
  }

  // FIXED: Changed parameter type from Delivery to Map<String, dynamic>
  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    // FIXED: Using bracket notation for all property access
    final deliveryId = delivery['id'] ?? 0;
    final deliveryFee = (delivery['delivery_fee'] ?? 0).toDouble();
    final driverEarning = (delivery['driver_earning'] ?? 0).toDouble();
    final distanceKm = (delivery['distance_km'] ?? 0).toDouble();
    final pickupAddress = delivery['pickup_address'] ?? 'Unknown';
    final deliveryAddress = delivery['delivery_address'] ?? 'Unknown';
    
    // Get order info
    final order = delivery['order'] as Map<String, dynamic>?;
    final orderNumber = order?['order_number'] ?? 'N/A';
    final item = order?['item'] as Map<String, dynamic>?;
    final itemTitle = item?['title'] ?? 'Unknown Item';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showAcceptDialog(delivery);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery #$deliveryId',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order: $orderNumber',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${driverEarning.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Item Info
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      itemTitle,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Addresses
              _buildAddressRow(
                Icons.location_on_outlined,
                'Pickup',
                pickupAddress,
              ),
              const SizedBox(height: 12),
              _buildAddressRow(
                Icons.location_on,
                'Delivery',
                deliveryAddress,
              ),
              const Divider(height: 24),

              // Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem(
                    Icons.route,
                    '${distanceKm.toStringAsFixed(1)} km',
                    'Distance',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildDetailItem(
                    Icons.attach_money,
                    '\$${deliveryFee.toStringAsFixed(2)}',
                    'Total Fee',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildDetailItem(
                    Icons.account_balance_wallet,
                    '\$${driverEarning.toStringAsFixed(2)}',
                    'You Earn',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Accept Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAcceptDialog(delivery),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Accept Delivery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _showAcceptDialog(Map<String, dynamic> delivery) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Delivery'),
        content: Text(
          'Do you want to accept delivery #${delivery['id']}?\n\n'
          'You will earn \$${((delivery['driver_earning'] ?? 0).toDouble()).toStringAsFixed(2)} for this delivery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<DeliveryProvider>();
      final success = await provider.acceptDelivery(delivery['id']);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to active delivery screen
        context.push('/driver/deliveries/${delivery['id']}');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to accept delivery'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}